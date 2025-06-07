module Flipper
  module Expressions
    class GreaterThan < Comparable
      def self.operator
        :>
      end

      def self.in_words(left, right)
        "#{left} is greater than #{right}"
      end
    end
  end
end
