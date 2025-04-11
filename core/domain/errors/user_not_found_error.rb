module Domain
  module Errors
    class UserNotFoundError < BaseError
      def initialize(message = "User not found.")
        super(
          message: message,
          error_code: "USER_NOT_FOUND",
          status_code: 404
        )
      end
    end
  end
end
