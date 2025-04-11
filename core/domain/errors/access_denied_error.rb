module Domain
  module Errors
    class AccessDeniedError < BaseError
      def initialize(message = "Access denied")
        super(
          message: message,
          error_code: "ACCESS_DENIED",
          status_code: 403
        )
      end
    end
  end
end
