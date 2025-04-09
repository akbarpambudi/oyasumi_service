# frozen_string_literal: true

require 'rails_helper'
require 'bcrypt'

RSpec.describe Domain::Entities::User do
  describe '#initialize' do
    let(:plain_password)   { "MySecret123" }
    let(:hashed_password)  { BCrypt::Password.create(plain_password) }

    it 'creates a user entity with valid name, email, and encrypted password' do
      user = described_class.new(
        name:  "Alice",
        email: "alice@example.com",
        encrypted_password: hashed_password
      )

      expect(user.name.value).to eq("Alice")
      expect(user.email.value).to eq("alice@example.com")
      expect(user.encrypted_password.hashed_value).to eq(hashed_password)
    end

    it 'raises an error if name is invalid' do
      expect {
        described_class.new(
          name: "",
          email: "alice@example.com",
          encrypted_password: hashed_password
        )
      }.to raise_error(Domain::Errors::InvalidNameError)
    end

    it 'raises an error if email is invalid' do
      expect {
        described_class.new(
          name: "Alice",
          email: "not_an_email",
          encrypted_password: hashed_password
        )
      }.to raise_error(Domain::Errors::InvalidEmailError)
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

  describe '#==' do
    it 'compares users by their ID' do
      user1 = described_class.new(id: 1, name: "Alice", email: "a@a.com", encrypted_password: "hash1")
      user2 = described_class.new(id: 1, name: "Alice", email: "a@a.com", encrypted_password: "hash2")
      user3 = described_class.new(id: 2, name: "Alice", email: "a@a.com", encrypted_password: "hash2")

      expect(user1).to eq(user2)   # same ID => equal in domain sense
      expect(user1).not_to eq(user3)
    end
  end
end
