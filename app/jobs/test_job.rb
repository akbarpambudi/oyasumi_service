class TestJob < ApplicationJob
  queue_as :default

  def perform(message)
    Rails.logger.info "TestJob received message: #{message}"
  end
end 