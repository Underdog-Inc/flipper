module Flipper
  module Expressions
    class GreaterThanOrEqualTo < Comparable
      def self.operator
        :>=
      end

      def self.in_words(left, right)
        "#{left} is greater than or equal to #{right}"
      end
    end
  end
end
