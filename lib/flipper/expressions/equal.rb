module Flipper
  module Expressions
    class Equal < Comparable
      def self.operator
        :==
      end

      def self.in_words(left, right)
        "#{left} is equal to #{right}"
      end
    end
  end
end
