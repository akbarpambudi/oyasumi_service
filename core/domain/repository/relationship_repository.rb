module Domain
  module Repository
    class RelationshipRepository
      def find_by(follower_id:, followed_id:)
        raise NotImplementedError
      end

      def create(entity)
        raise NotImplementedError
      end

      def delete(id)
        raise NotImplementedError
      end

      def followed_ids_for(user_id)
        raise NotImplementedError
      end
    end
  end
end
