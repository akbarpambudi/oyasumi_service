module Application
  class SleepRecordsAppService
    def initialize(
      sleep_record_repository = Domain::Repository::SleepRecordRepository.new
    )
      @sleep_record_repo = sleep_record_repository
    end

    # Clock in: create a new SleepRecord with start_time = now
    # Returns array of all the user's SleepRecords (ordered by creation desc).
    def clock_in(user_id:)
      record = Domain::Entities::SleepRecord.new(
        id: nil,
        user_id: user_id,
        start_time: Time.current
      )
      @sleep_record_repo.create(record)
      # Return updated list
      @sleep_record_repo.find_all_by_user(user_id)
    end

    # Clock out: sets end_time
    def clock_out(record_id:, user_id:)
      sr = @sleep_record_repo.find(record_id)
      raise Domain::Errors::SleepRecordNotFoundError unless sr
      raise Domain::Errors::AccessDeniedError if sr.user_id != user_id

      sr.end_time = Time.current
      @sleep_record_repo.update(sr)
      sr
    end

    # List the user’s SleepRecords (ordered by creation desc).
    def list_records(user_id:, page: nil, per_page: nil)
      if page.nil? or page < 1
        page = 1
      end
      if per_page.nil? or per_page < 1
        per_page = 1
      end
      paged_records, total_count = @sleep_record_repo.find_all_by_user_paginated(
        user_id,
        page: page,
        per_page: per_page
      )

      {
        page: page,
        per_page: per_page,
        total_count: total_count,
        records: paged_records
      }
    end
  end
end
