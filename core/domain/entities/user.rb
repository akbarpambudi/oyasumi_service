module Domain
  module Entities
    class User
      attr_reader :id, :name, :email, :encrypted_password, :created_at, :updated_at

      def initialize(id: nil, name:, email:, encrypted_password:, created_at: nil, updated_at: nil)
        @id = id
        self.name  = name
        self.email = email
        self.encrypted_password = encrypted_password
        @created_at = created_at
        @updated_at = updated_at
      end

      def name=(new_name)
        @name = if new_name.is_a?(Domain::ValueObjects::Name)
                  new_name
                else
                  Domain::ValueObjects::Name.new(new_name)
                end
      end

      def email=(new_email)
        @email = if new_email.is_a?(Domain::ValueObjects::Email)
                   new_email
                 else
                   Domain::ValueObjects::Email.new(new_email)
                 end
      end

      def encrypted_password=(value)
        @encrypted_password =
          if value.is_a?(Domain::ValueObjects::EncryptedPassword)
            value
          else
            Domain::ValueObjects::EncryptedPassword.new(hashed_value: value)
          end
      end

      # Domain-level method to verify a user's plain-text password
      def authenticate?(plain_password)
        encrypted_password.matches?(plain_password)
      end

      def ==(other)
        other.is_a?(User) && other.id == id
      end
    end
  end
end