module Domain
  module Entities
  end
end

# Require all entity classes
Dir[File.join(__dir__, 'entities', '*.rb')].sort.each { |file| require file } 