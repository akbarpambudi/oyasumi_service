# app/infrastructure/services/jwt_service.rb
require 'jwt'

module Infrastructure
  module Services
    class JwtService
      SECRET_KEY = Rails.application.credentials.jwt_secret!

      def self.encode(payload, exp = 24.hours.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload, SECRET_KEY, 'HS256')
      end

      def self.decode(token)
        decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
        decoded[0] # The payload
      rescue JWT::DecodeError => e
        raise Domain::Errors::InvalidTokenError, message: e.message
      end
    end
  end
end
