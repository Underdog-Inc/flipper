module Flipper
  module Expressions
    class Any
      def self.call(*args)
        args.any?
      end

      def self.in_words(*conditions)
        count = conditions.length
        "any #{count} condition#{'s' if count != 1}"
      end
    end
  end
end
