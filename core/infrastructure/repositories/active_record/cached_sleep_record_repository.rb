module Infrastructure
  module Repositories
    module ActiveRecord
      class CachedSleepRecordRepository
        CACHE_EXPIRY = 5.minutes
        MAX_CACHE_SIZE = 1000 # Maximum number of items in cache

        def initialize(repository)
          @repository = repository
        end

        def find(id)
          cache_key = "sleep_record:#{id}"
          access_key = "lru:access:#{cache_key}"
          
          cached_data = $redis.get(cache_key)

          if cached_data
            # Update access time for LRU
            $redis.zadd("lru:keys", Time.now.to_f, cache_key)
            return to_entity(JSON.parse(cached_data))
          end

          result = @repository.find(id)
          if result
            # Add to cache with LRU tracking
            $redis.multi do |redis|
              redis.setex(cache_key, CACHE_EXPIRY, result.to_json)
              redis.zadd("lru:keys", Time.now.to_f, cache_key)
            end
            cleanup_cache if cache_full?
          end
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
            # Update access time for LRU
            $redis.zadd("lru:keys", Time.now.to_f, cache_key)
            return JSON.parse(cached_data).map { |record| to_entity(record) }
          end

          entities = @repository.find_all_by_user(user_id)
          # Add to cache with LRU tracking
          $redis.multi do |redis|
            redis.setex(cache_key, CACHE_EXPIRY, entities.to_json)
            redis.zadd("lru:keys", Time.now.to_f, cache_key)
          end
          cleanup_cache if cache_full?
          entities
        end

        def find_completed_since(user_ids:, since:)
          cache_key = "completed_since:#{user_ids.join(',')}:#{since}"
          cached_data = $redis.get(cache_key)

          if cached_data
            # Update access time for LRU
            $redis.zadd("lru:keys", Time.now.to_f, cache_key)
            return JSON.parse(cached_data).map { |record| to_entity(record) }
          end

          entities = @repository.find_completed_since(user_ids: user_ids, since: since)
          # Add to cache with LRU tracking
          $redis.multi do |redis|
            redis.setex(cache_key, CACHE_EXPIRY, entities.to_json)
            redis.zadd("lru:keys", Time.now.to_f, cache_key)
          end
          cleanup_cache if cache_full?
          entities
        end

        def find_all_by_user_paginated(user_id, page:, per_page:)
          cache_key = "user:#{user_id}:sleep_records:page:#{page}:per_page:#{per_page}"
          cached_data = $redis.get(cache_key)

          if cached_data
            # Update access time for LRU
            $redis.zadd("lru:keys", Time.now.to_f, cache_key)
            data = JSON.parse(cached_data)
            return [data['records'].map { |record| to_entity(record) }, data['total_count']]
          end

          records, total_count = @repository.find_all_by_user_paginated(user_id, page: page, per_page: per_page)
          # Add to cache with LRU tracking
          $redis.multi do |redis|
            redis.setex(cache_key, CACHE_EXPIRY, { records: records, total_count: total_count }.to_json)
            redis.zadd("lru:keys", Time.now.to_f, cache_key)
          end
          cleanup_cache if cache_full?
          [records, total_count]
        end

        def find_completed_since_paginated(user_ids:, since:, page:, per_page:, sort: :duration_desc)
          cache_key = "completed_since_paginated:#{user_ids.join(',')}:#{since}:#{page}:#{per_page}:#{sort}"
          cached_data = $redis.get(cache_key)

          if cached_data
            # Update access time for LRU
            $redis.zadd("lru:keys", Time.now.to_f, cache_key)
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
          # Add to cache with LRU tracking
          $redis.multi do |redis|
            redis.setex(cache_key, CACHE_EXPIRY, { records: records, total_count: total_count }.to_json)
            redis.zadd("lru:keys", Time.now.to_f, cache_key)
          end
          cleanup_cache if cache_full?
          [records, total_count]
        end

        private

        def invalidate_user_cache(user_id)
          # Delete all cache keys related to this user
          keys = $redis.keys("user:#{user_id}:*")
          if keys.any?
            $redis.multi do |redis|
              redis.del(*keys)
              redis.zrem("lru:keys", *keys)
            end
          end
        end

        def invalidate_record_cache(record_id)
          cache_key = "sleep_record:#{record_id}"
          $redis.multi do |redis|
            redis.del(cache_key)
            redis.zrem("lru:keys", cache_key)
          end
        end

        def cache_full?
          $redis.zcard("lru:keys") >= MAX_CACHE_SIZE
        end

        def cleanup_cache
          # Get the oldest 10% of keys
          num_to_remove = (MAX_CACHE_SIZE * 0.1).to_i
          oldest_keys = $redis.zrange("lru:keys", 0, num_to_remove - 1)
          
          if oldest_keys.any?
            $redis.multi do |redis|
              redis.del(*oldest_keys)
              redis.zrem("lru:keys", *oldest_keys)
            end
          end
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