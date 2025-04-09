module Domain
  module ValueObjects
    class Name
      attr_reader :value

      def initialize(value)
        @value = sanitize(value)
        validate!
      end

      def ==(other)
        other.is_a?(Name) && other.value == value
      end

      private

      def validate!
        if @value.nil? || @value.strip.empty?
          raise Domain::Errors::InvalidNameError, message: "Name cannot be empty."
        end
      end

      def sanitize(input)
        input.to_s.strip
      end
    end
  end
end