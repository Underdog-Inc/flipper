module Flipper
  module UI
    class ExpressionSerializer

      # Public: Serialize an expression object to form data
      #
      # expression - A Flipper::Expression object or nil
      #
      # Returns a hash with form data structure
      def self.serialize(expression)
        return { type: "property" } if expression.nil?

        expression_type = determine_expression_type(expression)

        case expression_type
        when :simple
          serialize_simple_expression(expression)
        when :complex_any, :complex_all
          serialize_complex_expression(expression, expression_type)
        else
          { type: "property" }
        end
      end

      # Public: Deserialize form parameters to an expression hash
      #
      # form_params - Hash of form parameters
      #
      # Returns a hash ready for Flipper::Expression.build
      def self.deserialize(form_params)
        # Check if this is a complex expression (any/all)
        if form_params['complex_expression_type']
          deserialize_complex_expression(form_params)
        else
          deserialize_simple_expression(form_params)
        end
      end

      private

      # Determine the type of expression: :simple, :complex_any, :complex_all, or :none
      def self.determine_expression_type(expression)
        return :none if expression.nil?

        expr_value = expression.value
        return :none unless expr_value.is_a?(Hash)

        # Check for complex expression first
        if expr_value.key?("Any") && expr_value["Any"].is_a?(Array)
          return :complex_any
        elsif expr_value.key?("All") && expr_value["All"].is_a?(Array)
          return :complex_all
        end

        # Check for simple expression
        expr_value.each do |operator, args|
          next unless args.is_a?(Array) && args.length == 2

          property_part = args[0]
          value_part = args[1]

          if property_part.is_a?(Hash) && property_part.key?("Property")
            property_name = property_part["Property"]&.first
            return :simple if property_name && !value_part.nil?
          end
        end

        :none
      end

      # Serialize a simple expression to form data
      def self.serialize_simple_expression(expression)
        expr_value = expression.value
        return { type: "property" } unless expr_value.is_a?(Hash)

        expr_value.each do |operator, args|
          serialized = serialize_single_expression_part(operator, args)
          if serialized
            return {
              type: "property",
              property: serialized[:property],
              operator: serialized[:operator],
              value: serialized[:value]
            }
          end
        end

        { type: "property" }
      end

      # Serialize a complex expression to form data
      def self.serialize_complex_expression(expression, expression_type)
        type_name = expression_type == :complex_any ? "any" : "all"
        expressions = []

        expr_value = expression.value
        operator_key = expression_type == :complex_any ? "Any" : "All"
        conditions = expr_value[operator_key]

        return { type: type_name, expressions: [] } unless conditions.is_a?(Array)

        conditions.each do |condition|
          if condition.is_a?(Hash)
            condition.each do |operator, args|
              serialized = serialize_single_expression_part(operator, args)
              expressions << serialized if serialized
            end
          end
        end

        {
          type: type_name,
          expressions: expressions
        }
      end

      # Serialize a single expression part (operator + args) to form data
      def self.serialize_single_expression_part(operator, args)
        return nil unless args.is_a?(Array) && args.length == 2

        property_part = args[0]
        value_part = args[1]

        return nil unless property_part.is_a?(Hash) && property_part.key?("Property")

        property_name = property_part["Property"]&.first
        return nil unless property_name && !value_part.nil?

        {
          property: property_name,
          operator: operator,
          value: value_part.to_s
        }
      end

      # Deserialize simple expression form parameters
      def self.deserialize_simple_expression(form_params)
        property = form_params['property_name'].to_s.strip
        operator = form_params['operator_class'].to_s.strip
        value = form_params['value'].to_s.strip

        expression_hash = deserialize_single_expression_part(property, operator, value)
        raise ArgumentError, "Invalid expression parameters" unless expression_hash

        expression_hash
      end

      # Deserialize complex expression form parameters
      def self.deserialize_complex_expression(form_params)
        complex_type = form_params['complex_expression_type'].to_s.strip
        complex_expressions = form_params['complex_expressions'] || {}

        # Build array of simple expressions
        expressions = []
        complex_expressions.each do |index, expression_data|
          property = expression_data['property_name'].to_s.strip
          operator = expression_data['operator_class'].to_s.strip
          value = expression_data['value'].to_s.strip

          next if property.empty? || operator.empty? || value.empty?

          expression_hash = deserialize_single_expression_part(property, operator, value)
          expressions << expression_hash if expression_hash
        end

        # Build complex expression hash
        case complex_type
        when 'any'
          { "Any" => expressions }
        when 'all'
          { "All" => expressions }
        else
          raise ArgumentError, "Unknown complex expression type: #{complex_type}"
        end
      end

      # Deserialize a single expression part from form parameters
      def self.deserialize_single_expression_part(property, operator, value)
        return nil if property.empty? || operator.empty? || value.empty?

        # Convert value to appropriate type
        parsed_value = convert_value_to_type(value, property)

        # Validate that this is a known operator
        valid_operators = %w[Equal NotEqual GreaterThan GreaterThanOrEqualTo LessThan LessThanOrEqualTo]
        unless valid_operators.include?(operator)
          raise ArgumentError, "Unknown operator: #{operator}"
        end

        # Build expression hash in the format: {"Equal": [{"Property": ["plan"]}, "basic"]}
        {
          operator => [
            { "Property" => [property] },
            parsed_value
          ]
        }
      end

      # Convert value to appropriate type based on property
      def self.convert_value_to_type(value, property)
        property_type = property_type_for(property)

        case property_type.to_s
        when 'boolean'
          value == 'true'
        when 'number'
          value.include?('.') ? value.to_f : value.to_i
        else # string or unknown property
          value
        end
      end

      # Get the property type for a given property name
      def self.property_type_for(property_name)
        properties = UI.configuration.expression_properties
        return nil unless properties

        # Try string key first, then symbol key
        definition = properties[property_name] || properties[property_name.to_sym]
        return nil unless definition

        definition[:type] || definition['type']
      end
    end
  end
end
