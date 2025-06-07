module Flipper
  module Expressions
    class LessThan < Comparable
      def self.operator
        :<
      end

      def self.in_words(left, right)
        "#{left} is less than #{right}"
      end
    end
  end
end
