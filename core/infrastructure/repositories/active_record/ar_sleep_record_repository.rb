module Infrastructure
  module Repositories
    module ActiveRecord
      class ArSleepRecordRepository
        def find(id)
          rec = SleepRecordRecord.find_by(id: id)
          rec && to_entity(rec)
        end

        def create(entity)
          rec = SleepRecordRecord.create!(
            user_id: entity.user_id,
            start_time: entity.start_time,
            end_time: entity.end_time
          )
          assign_back(rec, entity)
        end

        def update(entity)
          rec = SleepRecordRecord.find(entity.id)
          rec.update!(
            start_time: entity.start_time,
            end_time: entity.end_time
          )
          assign_back(rec, entity)
        end

        def find_all_by_user(user_id)
          recs = SleepRecordRecord.where(user_id: user_id).includes(:user).order(created_at: :desc)
          recs.map { |r| to_entity(r) }
        end

        def find_completed_since(user_ids:, since:)
          return [] if user_ids.empty?
          recs = SleepRecordRecord
                   .where(user_id: user_ids)
                   .where('start_time >= ?', since)
                   .where.not(end_time: nil)
                   .includes(:user)
          recs.map { |r| to_entity(r) }
        end

        def find_all_by_user_paginated(user_id, page:, per_page:)
          offset = (page - 1) * per_page

          records = SleepRecordRecord
                      .where(user_id: user_id)
                      .includes(:user)
                      .order(created_at: :desc)
                      .offset(offset)
                      .limit(per_page)

          total_count = SleepRecordRecord.where(user_id: user_id).count

          [records.map { |r| to_entity(r) }, total_count]
        end

        def find_completed_since_paginated(user_ids:, since:, page:, per_page:, sort: :duration_desc)
          return [[], 0] if user_ids.empty?

          offset = (page - 1) * per_page
          base_query = SleepRecordRecord
                         .where(user_id: user_ids)
                         .where('start_time >= ?', since)
                         .where.not(end_time: nil)
                         .includes(:user)

          total_count = base_query.count

          # Sort by duration in SQL: (end_time - start_time)
          # For Postgres, we can do something like: Arel.sql("(extract(epoch from end_time) - extract(epoch from start_time)) DESC")
          # or simpler: Arel.sql("(end_time - start_time) DESC") works in Postgres as well
          order_clause =
            case sort
            when :duration_asc
              Arel.sql("(end_time - start_time) ASC")
            else
              Arel.sql("(end_time - start_time) DESC")
            end

          records = base_query
                      .order(order_clause)
                      .offset(offset)
                      .limit(per_page)

          [records.map { |r| to_entity(r) }, total_count]
        end

        private

        def to_entity(r)
          Domain::Entities::SleepRecord.new(
            id: r.id,
            user_id: r.user_id,
            start_time: r.start_time,
            end_time: r.end_time,
            created_at: r.created_at,
            updated_at: r.updated_at
          )
        end

        def assign_back(ar_record, entity)
          entity.id = ar_record.id
          entity.created_at = ar_record.created_at
          entity.updated_at = ar_record.updated_at
          entity
        end
      end
    end
  end
end
