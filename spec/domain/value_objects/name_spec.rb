require "rails_helper"

RSpec.describe Domain::ValueObjects::Name do
  describe "#initialize" do
    it "strips and stores the given name" do
      name_vo = Domain::ValueObjects::Name.new("  Alice  ")
      expect(name_vo.value).to eq("Alice")
    end

    it "raises an error if name is empty" do
      expect {
        Domain::ValueObjects::Name.new("")
      }.to raise_error(Domain::Errors::InvalidNameError, /cannot be empty/i)
    end
  end

  describe "#==" do
    it "considers two Name objects equal if they have the same value" do
      name1 =  Domain::ValueObjects::Name.new("Alice")
      name2 =  Domain::ValueObjects::Name.new("Alice")

      expect(name1).to eq(name2)
    end

    it "considers them different if the values differ" do
      name1 =  Domain::ValueObjects::Name.new("Alice")
      name2 =  Domain::ValueObjects::Name.new("Bob")

      expect(name1).not_to eq(name2)
    end
  end
end
