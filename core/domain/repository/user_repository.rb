# frozen_string_literal: true

module Domain
  module Repository
    class UserRepository
      def find_by_email(email_vo)
        raise NotImplementedError.new(message: "UserRepository.find_by_email is not implemented")
      end

      def find_by_id(id)
        raise NotImplementedError.new(message: "UserRepository.find_by_id is not implemented")
      end

      def save(user_entity)
        raise NotImplementedError.new(message: "UserRepository.save(user_entity)is not implemented")
      end

      def find_all_paginated(page:, per_page:)
        raise NotImplementedError.new(message: "UserRepository.find_all_paginated is not implemented")
      end
    end
  end
end
