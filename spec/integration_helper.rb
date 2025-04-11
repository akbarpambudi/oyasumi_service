require 'rails_helper'

RSpec.configure do |config|
  # Mark all tests in these directories as integration tests
  config.define_derived_metadata(file_path: %r{/spec/(controllers|requests|infrastructure)/}) do |metadata|
    metadata[:type] = :integration
  end

  config.before(:each, type: :integration) do
    # Reset any integration test specific setup
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each, type: :integration) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end 