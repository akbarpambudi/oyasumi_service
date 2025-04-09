module Domain
  module Errors
    class InvalidNameError < BaseError
      def initialize(message = "Invalid name")
        super(
          message: message,
          error_code: "INVALID_NAME",
          http_status: 422
        )
      end
    end
  end
end