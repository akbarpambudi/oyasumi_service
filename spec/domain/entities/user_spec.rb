# frozen_string_literal: true

require 'support/test_helpers/domain_helper'
require 'bcrypt'

RSpec.describe Domain::Entities::User do
  let(:valid_email) { Domain::ValueObjects::Email.new("test@example.com") }
  let(:valid_name) { Domain::ValueObjects::Name.new("John Doe") }
  let(:valid_password) { Domain::ValueObjects::EncryptedPassword.new(hashed_value: BCrypt::Password.create("password123")) }

  describe "#initialize" do
    it "creates a user with valid attributes" do
      user = described_class.new(
        id: 1,
        email: valid_email,
        name: valid_name,
        encrypted_password: valid_password
      )

      expect(user.id).to eq(1)
      expect(user.email).to eq(valid_email)
      expect(user.name).to eq(valid_name)
      expect(user.encrypted_password).to eq(valid_password)
    end

    it "allows id to be nil for new users" do
      user = described_class.new(
        email: valid_email,
        name: valid_name,
        encrypted_password: valid_password
      )

      expect(user.id).to be_nil
    end
  end

  describe "#==" do
    it "considers two users equal if they have the same id" do
      user1 = described_class.new(
        id: 1,
        email: valid_email,
        name: valid_name,
        encrypted_password: valid_password
      )

      user2 = described_class.new(
        id: 1,
        email: Domain::ValueObjects::Email.new("other@example.com"),
        name: Domain::ValueObjects::Name.new("Jane Doe"),
        encrypted_password: Domain::ValueObjects::EncryptedPassword.new(
          hashed_value: BCrypt::Password.create("different123")
        )
      )

      expect(user1).to eq(user2)
    end

    it "considers users different if they have different ids" do
      user1 = described_class.new(
        id: 1,
        email: valid_email,
        name: valid_name,
        encrypted_password: valid_password
      )

      user2 = described_class.new(
        id: 2,
        email: valid_email,
        name: valid_name,
        encrypted_password: valid_password
      )

      expect(user1).not_to eq(user2)
    end

    it "returns false when comparing with a different type" do
      user = described_class.new(
        id: 1,
        email: valid_email,
        name: valid_name,
        encrypted_password: valid_password
      )

      expect(user).not_to eq("not a user")
    end
  end

  describe '#authenticate?' do
    let(:plain_password)  { "MySecret123" }
    let(:wrong_password)  { "WrongPass" }
    let(:hashed_value)    { BCrypt::Password.create(plain_password) }
    let(:user) {
      described_class.new(
        name:  "Alice",
        email: "alice@example.com",
        encrypted_password: hashed_value
      )
    }

    it 'returns true if the given password matches the encrypted password' do
      expect(user.authenticate?(plain_password)).to be true
    end

    it 'returns false if the password does not match' do
      expect(user.authenticate?(wrong_password)).to be false
    end
  end
end
