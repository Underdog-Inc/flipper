module Flipper
  module Expressions
    class Include
      def self.call(left, right)
        left.respond_to?(:include?) && left.include?(right)
      end

      def self.in_words(left, right)
        "#{left.in_words} include #{right.in_words}"
      end
    end
  end
end
