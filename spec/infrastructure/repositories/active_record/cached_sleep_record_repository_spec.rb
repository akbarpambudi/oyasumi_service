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
    
    # Setup Redis mock
    allow($redis).to receive(:get).and_return(nil)
    allow($redis).to receive(:setex).and_return(true)
    allow($redis).to receive(:del).and_return(true)
    allow($redis).to receive(:keys).and_return([])
    allow($redis).to receive(:zadd).and_return(true)
    allow($redis).to receive(:zcard).and_return(0)
    allow($redis).to receive(:zrange).and_return([])
    allow($redis).to receive(:zrem).and_return(true)
    
    # Setup multi block handling
    allow($redis).to receive(:multi).and_yield($redis)
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

      it 'returns the cached data and updates LRU' do
        result = cached_repository.find(id)
        expect(result).to be_a(Core::Domain::Entities::SleepRecord)
        expect(result.id).to eq(id)
        expect(repository).not_to have_received(:find)
        expect($redis).to have_received(:zadd).with("lru:keys", anything, "sleep_record:#{id}")
      end
    end

    context 'when data is not cached' do
      before do
        allow($redis).to receive(:get).with("sleep_record:#{id}").and_return(nil)
        allow(repository).to receive(:find).with(id).and_return(sleep_record)
      end

      it 'fetches from repository and caches with LRU tracking' do
        result = cached_repository.find(id)
        expect(result).to eq(sleep_record)
        expect($redis).to have_received(:multi)
        expect($redis).to have_received(:setex).with("sleep_record:#{id}", 5.minutes, sleep_record.to_json)
        expect($redis).to have_received(:zadd).with("lru:keys", anything, "sleep_record:#{id}")
      end
    end

    context 'when cache is full' do
      before do
        allow($redis).to receive(:zcard).and_return(described_class::MAX_CACHE_SIZE)
        allow($redis).to receive(:get).with("sleep_record:#{id}").and_return(nil)
        allow(repository).to receive(:find).with(id).and_return(sleep_record)
        allow($redis).to receive(:zrange).and_return(["old_key1", "old_key2"])
      end

      it 'evicts least recently used items' do
        result = cached_repository.find(id)
        expect(result).to eq(sleep_record)
        expect($redis).to have_received(:zrange).with("lru:keys", 0, 99)  # 10% of MAX_CACHE_SIZE
        expect($redis).to have_received(:del).with("old_key1", "old_key2")
        expect($redis).to have_received(:zrem).with("lru:keys", "old_key1", "old_key2")
      end
    end

    context 'LRU behavior with multiple records' do
      let(:records) do
        3.times.map do |i|
          Core::Domain::Entities::SleepRecord.new(
            id: i + 1,
            user_id: 1,
            start_time: Time.current - i.hours
          )
        end
      end

      before do
        # Initially, no records are cached
        records.each do |record|
          allow(repository).to receive(:find).with(record.id).and_return(record)
        end
      end

      it 'maintains correct LRU order when accessing records' do
        # Access records in sequence: 1, 2, 3
        records.each do |record|
          cached_repository.find(record.id)
        end

        # Verify LRU tracking for initial access
        records.each do |record|
          expect($redis).to have_received(:zadd).with("lru:keys", anything, "sleep_record:#{record.id}")
        end

        # Simulate cache hit for record 1 (making it most recently used)
        allow($redis).to receive(:get).with("sleep_record:1").and_return(records[0].to_json)
        cached_repository.find(1)

        # Verify LRU update for record 1
        expect($redis).to have_received(:zadd).with("lru:keys", anything, "sleep_record:1").twice
      end

      it 'handles cache eviction when accessing many records' do
        allow($redis).to receive(:zcard).and_return(described_class::MAX_CACHE_SIZE)
        allow($redis).to receive(:zrange).and_return(["sleep_record:1", "sleep_record:2"])

        # Access a new record when cache is full
        new_record = Core::Domain::Entities::SleepRecord.new(
          id: 4,
          user_id: 1,
          start_time: Time.current
        )
        allow(repository).to receive(:find).with(4).and_return(new_record)

        cached_repository.find(4)

        # Verify old records were evicted
        expect($redis).to have_received(:del).with("sleep_record:1", "sleep_record:2")
        expect($redis).to have_received(:zrem).with("lru:keys", "sleep_record:1", "sleep_record:2")
        
        # Verify new record was cached
        expect($redis).to have_received(:setex).with("sleep_record:4", 5.minutes, new_record.to_json)
        expect($redis).to have_received(:zadd).with("lru:keys", anything, "sleep_record:4")
      end

      it 'updates LRU order on cache hits' do
        # First, cache all records
        records.each do |record|
          allow($redis).to receive(:get).with("sleep_record:#{record.id}").and_return(record.to_json)
          cached_repository.find(record.id)
        end

        # Access records in reverse order to change LRU order
        records.reverse_each do |record|
          cached_repository.find(record.id)
        end

        # Each record should have been accessed twice (initial + reverse order)
        records.each do |record|
          expect($redis).to have_received(:zadd).with("lru:keys", anything, "sleep_record:#{record.id}").twice
        end
      end
    end

    context 'LRU behavior with multiple users' do
      let(:user_records) do
        3.times.map do |i|
          user_id = i + 1
          records = [
            Core::Domain::Entities::SleepRecord.new(
              id: i + 1,
              user_id: user_id,
              start_time: Time.current
            )
          ]
          [user_id, records]
        end.to_h
      end

      before do
        user_records.each do |user_id, records|
          allow(repository).to receive(:find_all_by_user).with(user_id).and_return(records)
        end
      end

      it 'maintains LRU order for multiple users data' do
        # Access records for all users
        user_records.each do |user_id, records|
          cached_repository.find_all_by_user(user_id)
        end

        # Verify LRU tracking for all users
        user_records.each do |user_id, _|
          expect($redis).to have_received(:zadd).with("lru:keys", anything, "user:#{user_id}:sleep_records")
        end

        # Simulate cache hit for first user (making it most recently used)
        allow($redis).to receive(:get).with("user:1:sleep_records").and_return(user_records[1].to_json)
        cached_repository.find_all_by_user(1)

        # Verify LRU update for first user
        expect($redis).to have_received(:zadd).with("lru:keys", anything, "user:1:sleep_records").twice
      end

      it 'handles cache eviction for user data when cache is full' do
        allow($redis).to receive(:zcard).and_return(described_class::MAX_CACHE_SIZE)
        allow($redis).to receive(:zrange).and_return(["user:1:sleep_records", "user:2:sleep_records"])

        # Access a new user's records when cache is full
        new_user_id = 4
        new_records = [
          Core::Domain::Entities::SleepRecord.new(
            id: 4,
            user_id: new_user_id,
            start_time: Time.current
          )
        ]
        allow(repository).to receive(:find_all_by_user).with(new_user_id).and_return(new_records)

        cached_repository.find_all_by_user(new_user_id)

        # Verify old user records were evicted
        expect($redis).to have_received(:del).with("user:1:sleep_records", "user:2:sleep_records")
        expect($redis).to have_received(:zrem).with("lru:keys", "user:1:sleep_records", "user:2:sleep_records")
        
        # Verify new user records were cached
        expect($redis).to have_received(:setex).with("user:4:sleep_records", 5.minutes, new_records.to_json)
        expect($redis).to have_received(:zadd).with("lru:keys", anything, "user:4:sleep_records")
      end

      it 'updates LRU order on user cache hits' do
        # First, cache all users' records
        user_records.each do |user_id, records|
          allow($redis).to receive(:get).with("user:#{user_id}:sleep_records").and_return(records.to_json)
          cached_repository.find_all_by_user(user_id)
        end

        # Access users in reverse order to change LRU order
        user_records.keys.reverse_each do |user_id|
          cached_repository.find_all_by_user(user_id)
        end

        # Each user's cache should have been accessed twice (initial + reverse order)
        user_records.each do |user_id, _|
          expect($redis).to have_received(:zadd).with("lru:keys", anything, "user:#{user_id}:sleep_records").twice
        end
      end

      it 'handles mixed record and user-level cache operations' do
        # First, cache individual records
        user_records[1].each do |record|
          allow($redis).to receive(:get).with("sleep_record:#{record.id}").and_return(record.to_json)
          cached_repository.find(record.id)
        end

        # Then cache user's records
        allow($redis).to receive(:get).with("user:1:sleep_records").and_return(user_records[1].to_json)
        cached_repository.find_all_by_user(1)

        # Verify both record and user-level LRU tracking
        user_records[1].each do |record|
          expect($redis).to have_received(:zadd).with("lru:keys", anything, "sleep_record:#{record.id}")
        end
        expect($redis).to have_received(:zadd).with("lru:keys", anything, "user:1:sleep_records")
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
        expect($redis).to have_received(:multi)
        expect($redis).to have_received(:setex).with("user:#{user_id}:sleep_records", 5.minutes, sleep_records.to_json)
        expect($redis).to have_received(:zadd).with("lru:keys", anything, "user:#{user_id}:sleep_records")
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
      expect($redis).to have_received(:multi)
      expect($redis).to have_received(:del).with('key1', 'key2')
      expect($redis).to have_received(:zrem).with("lru:keys", 'key1', 'key2')
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

    it 'invalidates both user and record cache with LRU tracking' do
      expect(cached_repository.update(entity)).to eq(result)
      expect($redis).to have_received(:multi).twice  # Once for user cache, once for record cache
      expect($redis).to have_received(:del).with('key1', 'key2')
      expect($redis).to have_received(:zrem).with("lru:keys", 'key1', 'key2')
      expect($redis).to have_received(:del).with("sleep_record:#{entity.id}")
      expect($redis).to have_received(:zrem).with("lru:keys", "sleep_record:#{entity.id}")
    end
  end
end 