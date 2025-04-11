# app/infrastructure/services/jwt_service.rb
require 'jwt'

module Infrastructure
  module Services
    class JwtService
      SECRET_KEY = if Rails.env.test?
        'test_secret_key'
      elsif Rails.env.development?
        ENV.fetch('JWT_SECRET_KEY', 'development_secret_key')
      else
        ENV.fetch('JWT_SECRET_KEY')
      end
      ALGORITHM = 'HS256'
      EXPIRATION_TIME = 24.hours

      def self.encode(payload)
        payload[:exp] = EXPIRATION_TIME.from_now.to_i
        JWT.encode(payload, SECRET_KEY, ALGORITHM)
      end

      def self.decode(token)
        JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM }).first
      rescue JWT::DecodeError
        nil
      end
    end
  end
end
