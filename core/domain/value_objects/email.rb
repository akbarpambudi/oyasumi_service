module Domain
  module ValueObjects
    class Email
      attr_reader :value

      def initialize(value)
        @value = sanitize(value)
        validate!
      end

      def ==(other)
        other.is_a?(Email) && other.value == value
      end

      private

      def validate!
        # Simple format check; adjust to your needs.
        unless /\A[^@\s]+@[^@\s]+\z/.match?(@value)
          raise Domain::Errors::InvalidEmailError, message: "Invalid email format."
        end
      end

      def sanitize(input)
        input.to_s.strip.downcase
      end
    end
  end
end