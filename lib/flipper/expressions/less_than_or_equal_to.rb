module Flipper
  module Expressions
    class LessThanOrEqualTo < Comparable
      def self.operator
        :<=
      end

      def self.in_words(left, right)
        "#{left} is less than or equal to #{right}"
      end
    end
  end
end
