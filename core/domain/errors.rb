# Define the module structure first
module Domain
  module Errors
  end
end

# Require base error first
require_relative 'errors/base_error'

# Then require all other error classes
Dir[File.join(__dir__, 'errors', '*.rb')].sort.each do |file|
  next if file.end_with?('base_error.rb') # Skip base error since we already required it
  require file
end 