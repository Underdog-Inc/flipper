module Flipper
  module Expressions
    class All
      def self.call(*args)
        args.all?
      end

      def self.in_words(*conditions)
        count = conditions.length
        "all #{count} condition#{'s' if count != 1}"
      end
    end
  end
end
