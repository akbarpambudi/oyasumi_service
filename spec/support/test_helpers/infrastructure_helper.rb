require 'rails_helper'
require 'database_cleaner/active_record'
require 'support/test_type'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    next if ENV['SKIP_DATABASE'] == 'true'
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    if ENV['SKIP_DATABASE'] == 'true'
      example.run
    else
      DatabaseCleaner.cleaning do
        example.run
      end
    end
  end

  # Mock Redis for all test types
  config.before(:each) do
    case ENV['TEST_TYPE']
    when 'unit'
      # For unit tests, strictly mock all external dependencies
      allow($redis).to receive(:get).and_return(nil)
      allow($redis).to receive(:set).and_return("OK")
      allow($redis).to receive(:setex).and_return(true)
      allow($redis).to receive(:del).and_return(true)
      allow($redis).to receive(:keys).and_return([])
    when 'integration'
      # For integration tests, use MockRedis
      require 'mock_redis'
      $redis = MockRedis.new
    when 'e2e'
      # For E2E tests, use actual Redis if available, otherwise MockRedis
      begin
        require 'redis'
        $redis = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/1')
        $redis.ping # Test connection
      rescue Redis::CannotConnectError
        require 'mock_redis'
        $redis = MockRedis.new
        puts "Warning: Redis not available, falling back to MockRedis for E2E tests"
      end
    end
  end

  # Clean up after each test
  config.after(:each) do
    if defined?($redis) && $redis.respond_to?(:flushdb)
      $redis.flushdb
    end
  end
end 