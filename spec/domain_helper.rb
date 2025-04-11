require 'rails_helper'

# Add the core directory to the load path
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'core'))

# Require domain errors
require 'domain/errors'

# Configure RSpec for domain tests
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # RSpec expectations config
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # RSpec mocks config
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Shared context metadata behavior
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Mark all tests in this directory as unit tests
  config.define_derived_metadata(file_path: %r{/spec/domain/}) do |metadata|
    metadata[:type] = :unit
  end

  config.before(:each) do
    # Clear any mocked dependencies
    DependencyContainer.clear
  end
end