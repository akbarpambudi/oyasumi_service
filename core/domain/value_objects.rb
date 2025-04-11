module Domain
  module ValueObjects
  end
end

# Require all value object classes
Dir[File.join(__dir__, 'value_objects', '*.rb')].sort.each { |file| require file } 