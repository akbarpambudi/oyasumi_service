module Domain
  module Entities
    class Relationship
      attr_accessor :id, :follower_id, :followed_id, :created_at, :updated_at

      def initialize(id:, follower_id:, followed_id:, created_at: nil, updated_at: nil)
        @id = id
        @follower_id = follower_id
        @followed_id = followed_id
        @created_at = created_at
        @updated_at = updated_at
      end
    end
  end
end
