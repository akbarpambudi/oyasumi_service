module Domain
  module Errors
    class InvalidPasswordHashError < BaseError
      def initialize(message = "Invalid password hash.")
        super(
          message: message,
          error_code: "INVALID_PASSWORD_HASH",
          status_code: 422
        )
      end
    end
  end
end