module Domain
  module Errors
    class SleepRecordNotFoundError < BaseError
      def initialize(message = "Sleep record not found")
        super(
          message: message,
          error_code: "SLEEP_RECORD_NOT_FOUND",
          status_code: 404
        )
      end
    end
  end
end
