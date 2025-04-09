module Domain
  module Errors
    class EmailAlreadyRegisteredError < BaseError
      def initialize(message = "Email already registered.")
        super(
          message: message,
          error_code: "EMAIL_ALREADY_REGISTERED",
          http_status: 409
        )
      end
    end
  end
end