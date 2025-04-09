require 'bcrypt'

module Application
  class AuthAppService
    def initialize(user_repository = Domain::Repository::UserRepository.new)
      @user_repository = user_repository
    end

    # Creating a user with a plain text password
    def sign_up(name:, email:, plain_password:)
      # Hash the password
      hashed_value = BCrypt::Password.create(plain_password)

      user_entity = Domain::Entities::User.new(
        name:              name,
        email:             email,
        encrypted_password: hashed_value
      )

      # Save the user
      @user_repository.save(user_entity)
      user_entity
    end

    # Sign in and check password
    def sign_in(email:, plain_password:)
      user = @user_repository.find_by_email(email)
      raise Domain::Errors::InvalidCredentialsError, "Invalid credentials." unless user

      unless user.authenticate?(plain_password)
        raise Domain::Errors::InvalidCredentialsError, "Invalid credentials."
      end

      Infrastructure::Services::JwtService.encode({ user_id: user.id })
    end

    def authenticate_token(token:)
      decoded_token = Infrastructure::Services::JwtService.decode(token)
      @user_repository.find_by_id(decoded_token[:user_id])
    rescue Domain::Errors::InvalidTokenError, Domain::Errors::UserNotFoundError => e
      raise Domain::Errors::InvalidTokenError
    end
  end
end