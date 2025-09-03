module Flipper
  module Expressions
    class Exclude
      def self.call(left, right)
        left.respond_to?(:exclude?) && left.exclude?(right)
      end

      def self.in_words(left, right)
        "#{left.in_words} exclude #{right.in_words}"
      end
    end
  end
end
