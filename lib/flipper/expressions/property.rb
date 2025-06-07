module Flipper
  module Expressions
    class Property
      def self.call(key, context:)
        context.dig(:properties, key.to_s)
      end

      def self.display_value(key_expression)
        # For property expressions, return the property name for display
        key_expression.value
      end
    end
  end
end
