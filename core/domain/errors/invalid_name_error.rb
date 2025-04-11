module Domain
  module Errors
    class InvalidNameError < BaseError
      def initialize(message: "Invalid name")
        super(
          message: message,
          error_code: "INVALID_NAME",
          status_code: 422
        )
      end
    end
  end
end