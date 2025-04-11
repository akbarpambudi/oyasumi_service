module Infrastructure
  module Repositories
    module ActiveRecord
      class ArUserRepository < Domain::Repository::UserRepository
        def find_by_email(email)
          record = ::UserRecord.find_by(email: email)
          record ? map_to_domain(record) : nil
        end

        def find_by_id(id)
          record = ::UserRecord.find_by(id: id)
          record ? map_to_domain(record) : nil
        end

        def save(user_entity)
          if user_entity.id
            record = ::UserRecord.find(user_entity.id)
            record.email = user_entity.email.value
            record.name = user_entity.name.value
            record.encrypted_password = user_entity.encrypted_password.hashed_value
            record.save!
          else
            record = ::UserRecord.create!(
              email: user_entity.email.value,
              name: user_entity.name.value,
              encrypted_password: user_entity.encrypted_password.hashed_value
            )
            user_entity.instance_variable_set(:@id, record.id)
          end
          user_entity
        rescue ::ActiveRecord::RecordNotUnique
          raise Domain::Errors::EmailAlreadyRegisteredError
        end

        def find_all_paginated(page:, per_page:)
          offset = (page - 1) * per_page
          records = ::UserRecord.order(created_at: :desc)
                               .offset(offset)
                               .limit(per_page)
          total_count = ::UserRecord.count

          [records.map { |r| map_to_domain(r) }, total_count]
        end

        private

        def map_to_domain(record)
          Domain::Entities::User.new(
            id: record.id,
            email: record.email,
            name: record.name,
            encrypted_password: Domain::ValueObjects::EncryptedPassword.new(
              hashed_value: record.encrypted_password
            ),
            created_at: record.created_at,
            updated_at: record.updated_at
          )
        end
      end
    end
  end
end
