require 'rails_helper'

RSpec.describe Domain::ValueObjects::Email do
  describe '#initialize' do
    it 'downcases the input and stores it' do
      email_vo = described_class.new("  ALICE@EXAMPLE.Com  ")
      expect(email_vo.value).to eq("alice@example.com")
    end

    it 'raises an error if format is invalid' do
      expect {
        described_class.new("not_an_email")
      }.to raise_error(Domain::Errors::InvalidEmailError, /invalid email/i)
    end
  end

  describe '#==' do
    it 'treats two Email objects with the same value as equal' do
      email1 = described_class.new("alice@example.com")
      email2 = described_class.new("ALICE@example.com")

      expect(email1).to eq(email2)
    end
  end
end
