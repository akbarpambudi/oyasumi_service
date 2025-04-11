require 'rails_helper'

module Core
  module Domain
    module Entities
      class SleepRecord
        attr_accessor :id, :user_id, :start_time, :end_time, :created_at, :updated_at

        def initialize(attributes = {})
          attributes.each do |key, value|
            send("#{key}=", value)
          end
        end

        def to_json(*args)
          {
            id: id,
            user_id: user_id,
            start_time: start_time,
            end_time: end_time,
            created_at: created_at,
            updated_at: updated_at
          }.to_json(*args)
        end
      end
    end
  end
end

RSpec.describe Infrastructure::Repositories::ActiveRecord::CachedSleepRecordRepository do
  let(:redis) { MockRedis.new }
  let(:repository) { instance_double(Infrastructure::Repositories::ActiveRecord::ArSleepRecordRepository) }
  let(:cached_repository) { described_class.new(repository) }

  before do
    allow(repository).to receive(:find)
    allow(repository).to receive(:find_all_by_user)
    allow(repository).to receive(:create)
    allow(repository).to receive(:update)
    allow(redis).to receive(:get).and_call_original
    allow(redis).to receive(:setex).and_call_original
    allow(redis).to receive(:del).and_call_original
    allow(redis).to receive(:keys).and_call_original
    allow($redis).to receive(:get).and_return(nil)
    allow($redis).to receive(:setex).and_return(true)
    allow($redis).to receive(:del).and_return(true)
    allow($redis).to receive(:keys).and_return([])
  end

  describe '#find' do
    let(:id) { 1 }
    let(:sleep_record) do
      Core::Domain::Entities::SleepRecord.new(
        id: id,
        user_id: 1,
        start_time: Time.current,
        end_time: nil
      )
    end

    context 'when data is cached' do
      before do
        allow($redis).to receive(:get).with("sleep_record:#{id}").and_return(sleep_record.to_json)
      end

      it 'returns the cached data' do
        result = cached_repository.find(id)
        expect(result).to be_a(Core::Domain::Entities::SleepRecord)
        expect(result.id).to eq(id)
        expect(repository).not_to have_received(:find)
      end
    end

    context 'when data is not cached' do
      before do
        allow($redis).to receive(:get).with("sleep_record:#{id}").and_return(nil)
        allow(repository).to receive(:find).with(id).and_return(sleep_record)
      end

      it 'fetches from repository and caches the result' do
        result = cached_repository.find(id)
        expect(result).to eq(sleep_record)
        expect($redis).to have_received(:setex).with("sleep_record:#{id}", 5.minutes, sleep_record.to_json)
      end
    end
  end

  describe '#find_all_by_user' do
    let(:user_id) { 1 }
    let(:sleep_records) do
      [
        Core::Domain::Entities::SleepRecord.new(
          id: 1,
          user_id: user_id,
          start_time: Time.current,
          end_time: nil
        )
      ]
    end

    context 'when data is cached' do
      before do
        allow($redis).to receive(:get).with("user:#{user_id}:sleep_records").and_return(sleep_records.to_json)
      end

      it 'returns the cached data' do
        result = cached_repository.find_all_by_user(user_id)
        expect(result).to all(be_a(Core::Domain::Entities::SleepRecord))
        expect(repository).not_to have_received(:find_all_by_user)
      end
    end

    context 'when data is not cached' do
      before do
        allow($redis).to receive(:get).with("user:#{user_id}:sleep_records").and_return(nil)
        allow(repository).to receive(:find_all_by_user).with(user_id).and_return(sleep_records)
      end

      it 'fetches from repository and caches the result' do
        result = cached_repository.find_all_by_user(user_id)
        expect(result).to eq(sleep_records)
        expect($redis).to have_received(:setex).with("user:#{user_id}:sleep_records", 5.minutes, sleep_records.to_json)
      end
    end
  end

  describe '#create' do
    let(:entity) do
      Core::Domain::Entities::SleepRecord.new(
        id: nil,
        user_id: 1,
        start_time: Time.current,
        end_time: nil
      )
    end
    let(:result) do
      Core::Domain::Entities::SleepRecord.new(
        id: 1,
        user_id: 1,
        start_time: Time.current,
        end_time: nil
      )
    end

    before do
      allow(repository).to receive(:create).with(entity).and_return(result)
      allow($redis).to receive(:keys).with("user:#{entity.user_id}:*").and_return(['key1', 'key2'])
    end

    it 'invalidates the cache and returns the result' do
      expect(cached_repository.create(entity)).to eq(result)
      expect($redis).to have_received(:del).with('key1', 'key2')
    end
  end

  describe '#update' do
    let(:entity) do
      Core::Domain::Entities::SleepRecord.new(
        id: 1,
        user_id: 1,
        start_time: Time.current,
        end_time: Time.current
      )
    end
    let(:result) { entity.dup }

    before do
      allow(repository).to receive(:update).with(entity).and_return(result)
      allow($redis).to receive(:keys).with("user:#{entity.user_id}:*").and_return(['key1', 'key2'])
    end

    it 'invalidates both user and record cache and returns the result' do
      expect(cached_repository.update(entity)).to eq(result)
      expect($redis).to have_received(:del).with('key1', 'key2')
      expect($redis).to have_received(:del).with("sleep_record:#{entity.id}")
    end
  end
end 