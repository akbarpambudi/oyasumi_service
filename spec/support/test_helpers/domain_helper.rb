require 'unit_helper'

# Load domain-specific test helpers
Dir[File.join(File.dirname(__FILE__), 'domain/**/*.rb')].each { |f| require f }

# Add the core directory to the load path
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..', 'core'))

# Require domain modules
require 'domain/errors'
require 'domain/value_objects'
require 'domain/entities'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end 