require 'rails_helper'
require 'database_cleaner/active_record'
require 'support/test_type'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  
  config.before(:suite) do
    next if ENV['SKIP_DATABASE'] == 'true'
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    next if ENV['SKIP_DATABASE'] == 'true'
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    next if ENV['SKIP_DATABASE'] == 'true'
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    next if ENV['SKIP_DATABASE'] == 'true'
    DatabaseCleaner.start
  end

  config.after(:each) do
    next if ENV['SKIP_DATABASE'] == 'true'
    DatabaseCleaner.clean
  end
end 