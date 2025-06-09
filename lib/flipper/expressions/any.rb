module Flipper
  module Expressions
    class Any
      def self.call(*args)
        args.any?
      end

      def self.in_words(*args)
        count = args.length
        "any #{count} condition#{'s' if count != 1}"
      end
    end
  end
end
