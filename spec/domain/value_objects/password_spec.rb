# frozen_string_literal: true

require 'support/test_helpers/domain_helper'
require 'bcrypt'

RSpec.describe Domain::ValueObjects::EncryptedPassword do
  let(:plain_password) { "password123" }
  let(:hashed_password) { BCrypt::Password.create(plain_password) }

  describe "#initialize" do
    it "creates an encrypted password with valid hash" do
      password = described_class.new(hashed_value: hashed_password)
      expect(password.hashed_value).to eq(hashed_password)
    end

    it "raises an error for invalid hash format" do
      expect {
        described_class.new(hashed_value: "not_a_hash")
      }.to raise_error(Domain::Errors::InvalidPasswordHashError)
    end

    it "strips whitespace from the hash" do
      password = described_class.new(hashed_value: "  #{hashed_password}  ")
      expect(password.hashed_value).to eq(hashed_password)
    end
  end

  describe "#matches?" do
    let(:password) { described_class.new(hashed_value: hashed_password) }

    it "returns true for matching plain password" do
      expect(password.matches?(plain_password)).to be true
    end

    it "returns false for non-matching plain password" do
      expect(password.matches?("wrong_password")).to be false
    end

    it "returns false for nil password" do
      expect(password.matches?(nil)).to be false
    end
  end

  describe "#==" do
    it "considers two EncryptedPassword objects equal if they have the same hash" do
      password1 = described_class.new(hashed_value: hashed_password)
      password2 = described_class.new(hashed_value: hashed_password)

      expect(password1).to eq(password2)
    end

    it "considers them different if the hashes differ" do
      password1 = described_class.new(hashed_value: hashed_password)
      password2 = described_class.new(hashed_value: BCrypt::Password.create("different123"))

      expect(password1).not_to eq(password2)
    end

    it "returns false when comparing with a different type" do
      password = described_class.new(hashed_value: hashed_password)
      expect(password).not_to eq(hashed_password)
    end
  end
end
