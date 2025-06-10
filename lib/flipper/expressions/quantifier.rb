module Flipper
  module Expressions
    class Quantifier
      def self.call(*args)
        raise NotImplementedError
      end

      def self.in_words(*args)
        raise NotImplementedError
      end
    end
  end
end
