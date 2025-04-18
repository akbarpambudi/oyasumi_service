module Domain
  module Errors
    class InvalidCredentialsError < BaseError
      def initialize(message = "Invalid credentials")
        super(
          message: message,
          error_code: "INVALID_CREDENTIALS",
          status_code: 401
        )
      end
    end
  end
end# frozen_string_literal: true

