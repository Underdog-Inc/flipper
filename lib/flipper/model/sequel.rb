module Flipper
  module Model
    module Sequel
      include Flipper::Identifier

      # Properties used to evaluate expressions
      def flipper_properties
        props = {"type" => self.class.name}.update(to_hash.transform_keys(&:to_s))
        props["kind"] = kind if respond_to?(:kind)
        props
      end
    end
  end
end
