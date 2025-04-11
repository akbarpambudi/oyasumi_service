require 'support/test_helpers/domain_helper'
require "domain/value_objects/name"

RSpec.describe Domain::ValueObjects::Name do
  describe "#initialize" do
    it "creates a name with valid value" do
      name = described_class.new("John Doe")
      expect(name.value).to eq("John Doe")
    end

    it "raises an error for empty name" do
      expect { described_class.new("") }.to raise_error(Domain::Errors::InvalidNameError)
    end

    it "raises an error for nil name" do
      expect { described_class.new(nil) }.to raise_error(Domain::Errors::InvalidNameError)
    end

    it "strips whitespace from the name" do
      name = described_class.new("  John Doe  ")
      expect(name.value).to eq("John Doe")
    end
  end

  describe "#==" do
    it "considers two Name objects equal if they have the same value" do
      name1 = described_class.new("Alice")
      name2 = described_class.new("Alice")

      expect(name1).to eq(name2)
    end

    it "considers them different if the values differ" do
      name1 = described_class.new("Alice")
      name2 = described_class.new("Bob")

      expect(name1).not_to eq(name2)
    end

    it "returns false when comparing with a different type" do
      name = described_class.new("Alice")
      expect(name).not_to eq("Alice")
    end
  end
end
