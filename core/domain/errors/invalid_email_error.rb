module Domain
  module Errors
    class InvalidEmailError < BaseError
      def initialize(message = "Invalid email.")
        super(
          message: message,
          error_code: "INVALID_EMAIL",
          http_status: 422
        )
      end
    end
  end
end