require "bcrypt"

module Domain
  module ValueObjects
    class EncryptedPassword
      attr_reader :hashed_value

      def initialize(hashed_value:)
        @hashed_value = hashed_value.to_s.strip
        validate_hash_format!
      end

      # Compares a plain-text password to the stored hash
      def matches?(plain_password)
        bcrypt_obj = BCrypt::Password.new(@hashed_value)
        bcrypt_obj == plain_password
      rescue BCrypt::Errors::InvalidHash
        false
      end

      def ==(other)
        other.is_a?(EncryptedPassword) && other.hashed_value == hashed_value
      end

      private

      def validate_hash_format!
        BCrypt::Password.new(@hashed_value)
      rescue BCrypt::Errors::InvalidHash
        raise Domain::Errors::InvalidPasswordHashError
      end
    end
  end
end
