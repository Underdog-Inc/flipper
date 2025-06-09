module Flipper
  module Expressions
    class All
      def self.call(*args)
        args.all?
      end

      def self.in_words(*args)
        count = args.length
        "all #{count} condition#{'s' if count != 1}"
      end
    end
  end
end
