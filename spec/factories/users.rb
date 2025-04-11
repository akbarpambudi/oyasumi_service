FactoryBot.define do
  factory :user_record do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    encrypted_password { BCrypt::Password.create('password123') }
    created_at { Time.current }
    updated_at { Time.current }
  end
end 