require 'rails_helper'

RSpec.describe Application::UsersAppService, type: :service do
  let(:user_repository) { instance_double(Domain::Repository::UserRepository) }
  subject(:users_app_service) { described_class.new(user_repository) }

  describe '#list_users' do
    let(:page) { 1 }
    let(:per_page) { 20 }
    let(:user_entity) do
      instance_double(
        Domain::Entities::User,
        id: 1,
        name: Domain::ValueObjects::Name.new('John Doe'),
        email: Domain::ValueObjects::Email.new('john@example.com')
      )
    end

    before do
      allow(user_repository).to receive(:find_all_paginated)
        .with(page: page, per_page: per_page)
        .and_return([[user_entity], 1])
    end

    it 'returns paginated users' do
      result = users_app_service.list_users(page: page, per_page: per_page)

      expect(result).to eq({
        page: page,
        per_page: per_page,
        total_count: 1,
        records: [user_entity]
      })

      expect(user_repository).to have_received(:find_all_paginated)
        .with(page: page, per_page: per_page)
    end
  end
end 