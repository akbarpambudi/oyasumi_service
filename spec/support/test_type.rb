module TestType
  def self.unit?
    ENV['TEST_TYPE'] == 'unit'
  end

  def self.integration?
    ENV['TEST_TYPE'] == 'integration'
  end

  def self.e2e?
    ENV['TEST_TYPE'] == 'e2e'
  end

  def self.all?
    ENV['TEST_TYPE'].nil? || ENV['TEST_TYPE'] == 'all'
  end
end

RSpec.configure do |config|
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