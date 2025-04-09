# frozen_string_literal: true

require 'rails_helper'
require 'bcrypt'

RSpec.describe Domain::ValueObjects::EncryptedPassword do
  let(:plain_password) { "MySecret123" }
  let(:hashed_value)   { BCrypt::Password.create(plain_password) }

  describe '#initialize' do
    it 'accepts a valid bcrypt hash' do
      ep = described_class.new(hashed_value: hashed_value)
      expect(ep.hashed_value).to eq(hashed_value)
    end

    it 'raises an error if the hash is invalid' do
      expect {
        described_class.new(hashed_value: "not_a_bcrypt_hash")
      }.to raise_error(Domain::Errors::InvalidPasswordHashError)
    end
  end

  describe '#matches?' do
    it 'returns true if the plain text matches the stored hash' do
      ep = described_class.new(hashed_value: hashed_value)
      expect(ep.matches?(plain_password)).to be true
    end

    it 'returns false if the plain text does not match' do
      ep = described_class.new(hashed_value: hashed_value)
      expect(ep.matches?("WrongPassword")).to be false
    end
  end
end
