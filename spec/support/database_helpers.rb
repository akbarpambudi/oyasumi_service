module DatabaseHelpers
  def self.with_database
    if ENV['SKIP_DATABASE'] == 'true'
      skip "Database tests skipped (SKIP_DATABASE=true)"
    else
      yield
    end
  end
end

RSpec.configure do |config|
  config.around(:each, :requires_db) do |example|
    DatabaseHelpers.with_database do
      example.run
    end
  end
end 