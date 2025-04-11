require 'support/test_helpers/domain_helper'

RSpec.describe Domain::ValueObjects::Email do
  describe "#initialize" do
    it "creates an email with valid value" do
      email = described_class.new("test@example.com")
      expect(email.value).to eq("test@example.com")
    end

    it "raises an error for invalid email format" do
      expect { described_class.new("not_an_email") }.to raise_error(Domain::Errors::InvalidEmailError)
    end

    it "raises an error for empty email" do
      expect { described_class.new("") }.to raise_error(Domain::Errors::InvalidEmailError)
    end

    it "raises an error for nil email" do
      expect { described_class.new(nil) }.to raise_error(Domain::Errors::InvalidEmailError)
    end

    it "strips whitespace from the email" do
      email = described_class.new("  test@example.com  ")
      expect(email.value).to eq("test@example.com")
    end

    it "converts email to lowercase" do
      email = described_class.new("TEST@EXAMPLE.COM")
      expect(email.value).to eq("test@example.com")
    end
  end

  describe "#==" do
    it "considers two Email objects equal if they have the same value" do
      email1 = described_class.new("test@example.com")
      email2 = described_class.new("test@example.com")

      expect(email1).to eq(email2)
    end

    it "considers them different if the values differ" do
      email1 = described_class.new("test1@example.com")
      email2 = described_class.new("test2@example.com")

      expect(email1).not_to eq(email2)
    end

    it "returns false when comparing with a different type" do
      email = described_class.new("test@example.com")
      expect(email).not_to eq("test@example.com")
    end
  end
end
