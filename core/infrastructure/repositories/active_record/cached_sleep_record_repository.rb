module Infrastructure
  module Repositories
    module ActiveRecord
      class CachedSleepRecordRepository
        CACHE_EXPIRY = 5.minutes

        def initialize(repository)
          @repository = repository
        end

        def find(id)
          cache_key = "sleep_record:#{id}"
          cached_data = $redis.get(cache_key)

          if cached_data
            return to_entity(JSON.parse(cached_data))
          end

          result = @repository.find(id)
          $redis.setex(cache_key, CACHE_EXPIRY, result.to_json) if result
          result
        end

        def create(entity)
          result = @repository.create(entity)
          invalidate_user_cache(entity.user_id)
          result
        end

        def update(entity)
          result = @repository.update(entity)
          invalidate_user_cache(entity.user_id)
          invalidate_record_cache(entity.id)
          result
        end

        def find_all_by_user(user_id)
          cache_key = "user:#{user_id}:sleep_records"
          cached_data = $redis.get(cache_key)

          if cached_data
            return JSON.parse(cached_data).map { |record| to_entity(record) }
          end

          entities = @repository.find_all_by_user(user_id)
          $redis.setex(cache_key, CACHE_EXPIRY, entities.to_json)
          entities
        end

        def find_completed_since(user_ids:, since:)
          cache_key = "completed_since:#{user_ids.join(',')}:#{since}"
          cached_data = $redis.get(cache_key)

          if cached_data
            return JSON.parse(cached_data).map { |record| to_entity(record) }
          end

          entities = @repository.find_completed_since(user_ids: user_ids, since: since)
          $redis.setex(cache_key, CACHE_EXPIRY, entities.to_json)
          entities
        end

        def find_all_by_user_paginated(user_id, page:, per_page:)
          cache_key = "user:#{user_id}:sleep_records:page:#{page}:per_page:#{per_page}"
          cached_data = $redis.get(cache_key)

          if cached_data
            data = JSON.parse(cached_data)
            return [data['records'].map { |record| to_entity(record) }, data['total_count']]
          end

          records, total_count = @repository.find_all_by_user_paginated(user_id, page: page, per_page: per_page)
          $redis.setex(cache_key, CACHE_EXPIRY, { records: records, total_count: total_count }.to_json)
          [records, total_count]
        end

        def find_completed_since_paginated(user_ids:, since:, page:, per_page:, sort: :duration_desc)
          cache_key = "completed_since_paginated:#{user_ids.join(',')}:#{since}:#{page}:#{per_page}:#{sort}"
          cached_data = $redis.get(cache_key)

          if cached_data
            data = JSON.parse(cached_data)
            return [data['records'].map { |record| to_entity(record) }, data['total_count']]
          end

          records, total_count = @repository.find_completed_since_paginated(
            user_ids: user_ids,
            since: since,
            page: page,
            per_page: per_page,
            sort: sort
          )
          $redis.setex(cache_key, CACHE_EXPIRY, { records: records, total_count: total_count }.to_json)
          [records, total_count]
        end

        private

        def invalidate_user_cache(user_id)
          # Delete all cache keys related to this user
          keys = $redis.keys("user:#{user_id}:*")
          $redis.del(*keys) if keys.any?
        end

        def invalidate_record_cache(record_id)
          $redis.del("sleep_record:#{record_id}")
        end

        def to_entity(record)
          Core::Domain::Entities::SleepRecord.new(
            id: record['id'],
            user_id: record['user_id'],
            start_time: record['start_time'],
            end_time: record['end_time'],
            created_at: record['created_at'],
            updated_at: record['updated_at']
          )
        end
      end
    end
  end
end 