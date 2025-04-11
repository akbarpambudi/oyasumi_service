module Domain
  module Errors
    class InvalidEmailError < BaseError
      def initialize(message = "Invalid email.")
        super(
          message: message,
          error_code: "INVALID_EMAIL",
          status_code: 422
        )
      end
    end
  end
end