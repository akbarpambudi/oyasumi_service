module Domain
  module Errors
    class BaseError < StandardError
      attr_reader :error_code, :status_code

      def initialize(message: "", error_code: "UNKNOWN_ERROR", status_code: 500)
        super(message)
        @error_code = error_code
        @status_code = status_code
      end
    end
  end
end 