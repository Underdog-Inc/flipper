module Flipper
  module Expressions
    class NotEqual < Comparable
      def self.operator
        :!=
      end

      def self.in_words(left, right)
        "#{left} is not equal to #{right}"
      end
    end
  end
end
