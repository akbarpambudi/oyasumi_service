require 'rails_helper'

RSpec.configure do |config|
  # Mark all tests in these directories as e2e tests
  config.define_derived_metadata(file_path: %r{/spec/e2e/}) do |metadata|
    metadata[:type] = :e2e
  end

  config.before(:each, type: :e2e) do
    # Use truncation strategy for e2e tests
    DatabaseCleaner.strategy = :truncation
  end

  config.around(:each, type: :e2e) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Additional E2E specific configuration
  config.before(:each, type: :e2e) do
    # Reset any external services or dependencies
    $redis.flushdb if defined?($redis)
  end
end 