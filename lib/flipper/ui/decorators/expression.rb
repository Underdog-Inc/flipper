require 'delegate'

module Flipper
  module UI
    module Decorators
      class Expression < SimpleDelegator
        # Public: The expression being decorated.
        alias_method :expression, :__getobj__

        # Public: Get complete form initialization data for JavaScript.
        # Combines form values with has_expression flag.
        def form_data
          data = form_values
          data[:has_expression] = present?
          data
        end

        private

        # Return true if we have a real expression object
        def present?
          !expression.nil?
        end

        # Determine the type of expression: :simple, :complex_any, :complex_all, or :none
        def type
          return :none unless present?

          # Check for simple expression first
          parse_simple_expression do |property_name, operator, value_part|
            return :simple
          end

          # Check for complex expression
          parse_complex_expression do |operator, conditions|
            return operator == "Any" ? :complex_any : :complex_all
          end

          :none
        end

        # Extract form values from current expression for editing.
        # Returns hash with type and expression data based on expression type.
        def form_values
          case type
          when :simple
            parse_simple_expression do |property_name, operator, value_part|
              form_operator = map_expression_operator_to_form(operator)
              return {
                type: "property",
                property: property_name,
                operator: form_operator,
                value: value_part.to_s
              }
            end
          when :complex_any, :complex_all
            return complex_expression_form_values
          else
            return { type: "property" }
          end
        end

        # Extract complex expression form values for editing.
        def complex_expression_form_values
          type_name = type == :complex_any ? "any" : "all"
          expressions = []

          parse_complex_expression do |operator, conditions|
            conditions.each do |condition|
              if condition.is_a?(Hash)
                condition.each do |cond_operator, cond_args|
                  next unless cond_args.is_a?(Array) && cond_args.length == 2

                  property_part = cond_args[0]
                  value_part = cond_args[1]

                  if property_part.is_a?(Hash) && property_part.has_key?("Property")
                    property_name = property_part["Property"]&.first
                    if property_name && !value_part.nil?
                      form_operator = map_expression_operator_to_form(cond_operator)
                      expressions << {
                        property: property_name,
                        operator: form_operator,
                        value: value_part.to_s
                      }
                    end
                  end
                end
              end
            end
          end

          {
            type: type_name,
            expressions: expressions
          }
        end

        # Map expression operator names to form operator codes.
        def map_expression_operator_to_form(operator)
          case operator
          when "Equal" then "eq"
          when "NotEqual" then "ne"
          when "GreaterThan" then "gt"
          when "GreaterThanOrEqualTo" then "gte"
          when "LessThan" then "lt"
          when "LessThanOrEqualTo" then "lte"
          else "eq" # Default fallback
          end
        end

        # Parse simple expression and yield property name, operator, and value if found.
        def parse_simple_expression
          return unless present?

          expr_value = expression.value
          return unless expr_value.is_a?(Hash)

          expr_value.each do |operator, args|
            next unless args.is_a?(Array) && args.length == 2

            property_part = args[0]
            value_part = args[1]

            if property_part.is_a?(Hash) && property_part.has_key?("Property")
              property_name = property_part["Property"]&.first
              if property_name && !value_part.nil?
                yield property_name, operator, value_part
              end
            end
          end
        end

        # Parse complex expression and yield operator type and conditions array if found.
        def parse_complex_expression
          return unless present?

          expr_value = expression.value
          return unless expr_value.is_a?(Hash)

          %w[Any All].each do |operator|
            if expr_value.has_key?(operator) && expr_value[operator].is_a?(Array)
              yield operator, expr_value[operator]
              return
            end
          end
        end
      end
    end
  end
end
