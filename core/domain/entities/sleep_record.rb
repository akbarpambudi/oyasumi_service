module Domain
  module Entities
    class SleepRecord
      attr_accessor :id, :user_id, :start_time, :end_time,
                    :created_at, :updated_at

      def initialize(id:, user_id:, start_time:, end_time: nil,
                     created_at: nil, updated_at: nil)
        @id         = id
        @user_id    = user_id
        @start_time = start_time
        @end_time   = end_time
        @created_at = created_at
        @updated_at = updated_at
      end

      def duration_in_seconds
        return nil unless end_time
        (end_time - start_time).to_i
      end
    end
  end
end
