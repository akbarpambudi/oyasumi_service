require 'rails_helper'

RSpec.describe Application::FriendshipsAppService, type: :service do
  let(:relationship_repository) { instance_double(Domain::Repository::RelationshipRepository) }
  let(:user_repository) { instance_double(Domain::Repository::UserRepository) }
  let(:sleep_record_repository) { instance_double(Domain::Repository::SleepRecordRepository) }
  
  subject(:friendships_app_service) do
    described_class.new(
      relationship_repository,
      user_repository,
      sleep_record_repository
    )
  end

  describe '#follow_user' do
    let(:follower_id) { 1 }
    let(:followed_id) { 2 }
    let(:followed_user) do
      instance_double(
        Domain::Entities::User,
        id: followed_id
      )
    end

    before do
      allow(user_repository).to receive(:find_by_id)
        .with(followed_id)
        .and_return(followed_user)
      allow(relationship_repository).to receive(:find_by)
        .with(follower_id: follower_id, followed_id: followed_id)
        .and_return(nil)
      allow(relationship_repository).to receive(:create)
    end

    it 'creates a new relationship' do
      result = friendships_app_service.follow_user(
        follower_id: follower_id,
        followed_id: followed_id
      )

      expect(result).to eq(:success)
      expect(user_repository).to have_received(:find_by_id)
        .with(followed_id)
      expect(relationship_repository).to have_received(:find_by)
        .with(follower_id: follower_id, followed_id: followed_id)
      expect(relationship_repository).to have_received(:create)
    end

    context 'when user is not found' do
      before do
        allow(user_repository).to receive(:find_by_id)
          .with(followed_id)
          .and_return(nil)
      end

      it 'raises UserNotFoundError' do
        expect {
          friendships_app_service.follow_user(
            follower_id: follower_id,
            followed_id: followed_id
          )
        }.to raise_error(Domain::Errors::UserNotFoundError)
      end
    end

    context 'when already following' do
      let(:existing_relationship) do
        instance_double(
          Domain::Entities::Relationship,
          id: 1,
          follower_id: follower_id,
          followed_id: followed_id
        )
      end

      before do
        allow(relationship_repository).to receive(:find_by)
          .with(follower_id: follower_id, followed_id: followed_id)
          .and_return(existing_relationship)
      end

      it 'returns :already_following' do
        result = friendships_app_service.follow_user(
          follower_id: follower_id,
          followed_id: followed_id
        )

        expect(result).to eq(:already_following)
      end
    end
  end

  describe '#unfollow_user' do
    let(:follower_id) { 1 }
    let(:followed_id) { 2 }
    let(:followed_user) do
      instance_double(
        Domain::Entities::User,
        id: followed_id
      )
    end
    let(:existing_relationship) do
      instance_double(
        Domain::Entities::Relationship,
        id: 1,
        follower_id: follower_id,
        followed_id: followed_id
      )
    end

    before do
      allow(user_repository).to receive(:find_by_id)
        .with(followed_id)
        .and_return(followed_user)
      allow(relationship_repository).to receive(:find_by)
        .with(follower_id: follower_id, followed_id: followed_id)
        .and_return(existing_relationship)
      allow(relationship_repository).to receive(:delete)
        .with(existing_relationship.id)
    end

    it 'deletes the relationship' do
      result = friendships_app_service.unfollow_user(
        follower_id: follower_id,
        followed_id: followed_id
      )

      expect(result).to eq(:success)
      expect(user_repository).to have_received(:find_by_id)
        .with(followed_id)
      expect(relationship_repository).to have_received(:find_by)
        .with(follower_id: follower_id, followed_id: followed_id)
      expect(relationship_repository).to have_received(:delete)
        .with(existing_relationship.id)
    end

    context 'when user is not found' do
      before do
        allow(user_repository).to receive(:find_by_id)
          .with(followed_id)
          .and_return(nil)
      end

      it 'raises UserNotFoundError' do
        expect {
          friendships_app_service.unfollow_user(
            follower_id: follower_id,
            followed_id: followed_id
          )
        }.to raise_error(Domain::Errors::UserNotFoundError)
      end
    end

    context 'when not following' do
      before do
        allow(relationship_repository).to receive(:find_by)
          .with(follower_id: follower_id, followed_id: followed_id)
          .and_return(nil)
      end

      it 'returns :not_following' do
        result = friendships_app_service.unfollow_user(
          follower_id: follower_id,
          followed_id: followed_id
        )

        expect(result).to eq(:not_following)
      end
    end
  end

  describe '#fetch_following_sleep_records' do
    let(:user_id) { 1 }
    let(:followed_ids) { [2, 3] }
    let(:page) { 1 }
    let(:per_page) { 20 }
    let(:sort) { :duration_desc }
    let(:fixed_time) { Time.utc(2024, 4, 1, 12, 0, 0) }
    let(:sleep_record) do
      instance_double(
        Domain::Entities::SleepRecord,
        id: 1,
        user_id: 2,
        start_time: fixed_time,
        end_time: fixed_time + 1.hour,
        created_at: fixed_time,
        updated_at: fixed_time
      )
    end

    before do
      allow(Time).to receive(:current).and_return(fixed_time)
      allow(relationship_repository).to receive(:followed_ids_for)
        .with(user_id)
        .and_return(followed_ids)
      allow(sleep_record_repository).to receive(:find_completed_since_paginated)
        .with(
          user_ids: followed_ids,
          since: fixed_time - 1.week,
          sort: sort,
          page: page,
          per_page: per_page
        )
        .and_return([[sleep_record], 1])
    end

    it 'returns paginated sleep records of followed users' do
      result = friendships_app_service.fetch_following_sleep_records(
        user_id: user_id,
        sort: sort,
        page: page,
        per_page: per_page
      )

      expect(result).to eq({
        records: [sleep_record],
        total_count: 1,
        page: page,
        per_page: per_page
      })

      expect(relationship_repository).to have_received(:followed_ids_for)
        .with(user_id)
      expect(sleep_record_repository).to have_received(:find_completed_since_paginated)
        .with(
          user_ids: followed_ids,
          since: fixed_time - 1.week,
          sort: sort,
          page: page,
          per_page: per_page
        )
    end
  end
end 