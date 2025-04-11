module Infrastructure
  module Repositories
      module ActiveRecord
        class ArRelationshipRepository < Domain::Repository::RelationshipRepository
          def find_by(follower_id:, followed_id:)
            rec = RelationshipRecord.find_by(
              follower_id: follower_id,
              followed_id: followed_id
            )
            rec && to_entity(rec)
          end

          def create(entity)
            rec = RelationshipRecord.create!(
              follower_id: entity.follower_id,
              followed_id: entity.followed_id
            )
            entity.id = rec.id
            entity.created_at = rec.created_at
            entity.updated_at = rec.updated_at
            entity
          end

          def delete(id)
            RelationshipRecord.where(id: id).destroy_all
          end

          def followed_ids_for(user_id)
            RelationshipRecord
              .where(follower_id: user_id)
              .pluck(:followed_id)
          end

          private

          def to_entity(r)
            Domain::Entities::Relationship.new(
              id: r.id,
              follower_id: r.follower_id,
              followed_id: r.followed_id,
              created_at: r.created_at,
              updated_at: r.updated_at
            )
          end
        end
      end
  end
end


