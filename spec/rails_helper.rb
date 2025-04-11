# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

# Skip database configuration for unit tests
if ENV['TEST_TYPE'] == 'unit'
  ENV['SKIP_DATABASE'] = 'true'
  puts "Skipping database configuration for unit tests"
end

# Skip database configuration if SKIP_DATABASE is true
unless ENV['SKIP_DATABASE'] == 'true'
  require_relative '../config/environment'
  # Prevent database truncation if the environment is production
  abort("The Rails environment is running in production mode!") if Rails.env.production?
end

require 'rspec/rails'
require 'support/test_type'

# Add additional requires below this line. Rails is not loaded until this point!

# Load all support files
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ] unless ENV['SKIP_DATABASE'] == 'true'

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Include FactoryBot methods
  config.include FactoryBot::Syntax::Methods

  # Load test type specific configurations
  config.before(:suite) do
    next if ENV['SKIP_DATABASE'] == 'true'

    case ENV['TEST_TYPE']
    when 'integration'
      # Integration tests use transaction strategy
      DatabaseCleaner.clean_with(:truncation)
      DatabaseCleaner.strategy = :transaction
    when 'e2e'
      # E2E tests use truncation strategy
      DatabaseCleaner.clean_with(:truncation)
      DatabaseCleaner.strategy = :truncation
    else
      # Default to transaction strategy
      DatabaseCleaner.clean_with(:truncation)
      DatabaseCleaner.strategy = :transaction
    end
  end

  config.before(:each) do |example|
    next if ENV['SKIP_DATABASE'] == 'true'

    # Set up database cleaning strategy based on test type
    if example.metadata[:js] || example.metadata[:type] == :e2e
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean unless ENV['SKIP_DATABASE'] == 'true'
  end

  # Filter tests based on their type
  config.before(:each, type: :unit) do |example|
    skip "Skipping unit test" unless TestType.unit? || TestType.all?
  end

  config.before(:each, type: :integration) do |example|
    skip "Skipping integration test" unless TestType.integration? || TestType.all?
  end

  config.before(:each, type: :e2e) do |example|
    skip "Skipping e2e test" unless TestType.e2e? || TestType.all?
  end
end

# Only check for pending migrations if we're using the database
unless ENV['SKIP_DATABASE'] == 'true'
  begin
    ActiveRecord::Migration.maintain_test_schema!
  rescue ActiveRecord::ConnectionNotEstablished => e
    raise e unless ENV['TEST_TYPE'] == 'unit'
  end
end
