module Domain
  module Errors
    class InvalidTokenError < BaseError
      def initialize(message = "Invalid or expired token.")
        super(
          message: message,
          error_code: "INVALID_TOKEN",
          http_status: 401
        )
      end
    end
  end
end
