require 'e2e_helper'

module ApiHelper
  def json_response
    JSON.parse(response.body)
  end

  def auth_headers(token)
    { 'Authorization' => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include ApiHelper, type: :e2e
  config.include Rails.application.routes.url_helpers, type: :e2e
  config.include ActionDispatch::Integration::Runner, type: :e2e
  config.include RSpec::Rails::RequestExampleGroup, type: :e2e

  config.before(:each, type: :e2e) do
    self.host = 'localhost:3000'
  end
end 