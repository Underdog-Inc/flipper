require 'flipper/ui/expression_serializer'

RSpec.describe Flipper::UI::ExpressionSerializer do
  let(:expression_properties) do
    {
      'plan' => { type: 'string' },
      'user_id' => { type: 'number' },
      'premium' => { type: 'boolean' }
    }
  end

  before do
    allow(Flipper::UI.configuration).to receive(:expression_properties).and_return(expression_properties)
  end

  describe '.serialize' do
    context 'with nil expression' do
      it 'returns default form data' do
        result = described_class.serialize(nil)
        expect(result).to eq({ type: "property" })
      end
    end

    context 'with simple expression' do
      let(:expression) do
        double(:expression, value: {
          "Equal" => [
            { "Property" => ["plan"] },
            "basic"
          ]
        })
      end

      it 'serializes to form data' do
        result = described_class.serialize(expression)
        expect(result).to eq({
          type: "property",
          property: "plan",
          operator: "Equal",
          value: "basic"
        })
      end
    end

    context 'with simple expression using different operators' do
      let(:not_equal_expression) do
        double(:expression, value: {
          "NotEqual" => [
            { "Property" => ["user_id"] },
            42
          ]
        })
      end

      let(:greater_than_expression) do
        double(:expression, value: {
          "GreaterThan" => [
            { "Property" => ["user_id"] },
            100
          ]
        })
      end

      it 'serializes NotEqual operator' do
        result = described_class.serialize(not_equal_expression)
        expect(result).to eq({
          type: "property",
          property: "user_id",
          operator: "NotEqual",
          value: "42"
        })
      end

      it 'serializes GreaterThan operator' do
        result = described_class.serialize(greater_than_expression)
        expect(result).to eq({
          type: "property",
          property: "user_id",
          operator: "GreaterThan",
          value: "100"
        })
      end
    end

    context 'with complex Any expression' do
      let(:expression) do
        double(:expression, value: {
          "Any" => [
            {
              "Equal" => [
                { "Property" => ["plan"] },
                "basic"
              ]
            },
            {
              "GreaterThan" => [
                { "Property" => ["user_id"] },
                100
              ]
            }
          ]
        })
      end

      it 'serializes to complex form data' do
        result = described_class.serialize(expression)
        expect(result).to eq({
          type: "any",
          expressions: [
            {
              property: "plan",
              operator: "Equal",
              value: "basic"
            },
            {
              property: "user_id",
              operator: "GreaterThan",
              value: "100"
            }
          ]
        })
      end
    end

    context 'with complex All expression' do
      let(:expression) do
        double(:expression, value: {
          "All" => [
            {
              "Equal" => [
                { "Property" => ["plan"] },
                "premium"
              ]
            },
            {
              "Equal" => [
                { "Property" => ["premium"] },
                true
              ]
            }
          ]
        })
      end

      it 'serializes to complex form data' do
        result = described_class.serialize(expression)
        expect(result).to eq({
          type: "all",
          expressions: [
            {
              property: "plan",
              operator: "Equal",
              value: "premium"
            },
            {
              property: "premium",
              operator: "Equal",
              value: "true"
            }
          ]
        })
      end
    end

    context 'with invalid expression structure' do
      let(:expression) do
        double(:expression, value: { "InvalidOperator" => ["invalid"] })
      end

      it 'returns default form data' do
        result = described_class.serialize(expression)
        expect(result).to eq({ type: "property" })
      end
    end
  end

  describe '.deserialize' do
    context 'with simple expression form params' do
      let(:form_params) do
        {
          'property_name' => 'plan',
          'operator_class' => 'Equal',
          'value' => 'basic'
        }
      end

      it 'deserializes to expression hash' do
        result = described_class.deserialize(form_params)
        expect(result).to eq({
          "Equal" => [
            { "Property" => ["plan"] },
            "basic"
          ]
        })
      end
    end

    context 'with number value conversion' do
      let(:form_params) do
        {
          'property_name' => 'user_id',
          'operator_class' => 'GreaterThan',
          'value' => '100'
        }
      end

      it 'converts string to integer' do
        result = described_class.deserialize(form_params)
        expect(result).to eq({
          "GreaterThan" => [
            { "Property" => ["user_id"] },
            100
          ]
        })
      end
    end

    context 'with float value conversion' do
      let(:form_params) do
        {
          'property_name' => 'user_id',
          'operator_class' => 'GreaterThanOrEqualTo',
          'value' => '99.5'
        }
      end

      it 'converts string to float' do
        result = described_class.deserialize(form_params)
        expect(result).to eq({
          "GreaterThanOrEqualTo" => [
            { "Property" => ["user_id"] },
            99.5
          ]
        })
      end
    end

    context 'with boolean value conversion' do
      let(:form_params) do
        {
          'property_name' => 'premium',
          'operator_class' => 'Equal',
          'value' => 'true'
        }
      end

      it 'converts string to boolean' do
        result = described_class.deserialize(form_params)
        expect(result).to eq({
          "Equal" => [
            { "Property" => ["premium"] },
            true
          ]
        })
      end
    end

    context 'with complex Any expression form params' do
      let(:form_params) do
        {
          'complex_expression_type' => 'any',
          'complex_expressions' => {
            '0' => {
              'property_name' => 'plan',
              'operator_class' => 'Equal',
              'value' => 'basic'
            },
            '1' => {
              'property_name' => 'user_id',
              'operator_class' => 'GreaterThan',
              'value' => '100'
            }
          }
        }
      end

      it 'deserializes to complex expression hash' do
        result = described_class.deserialize(form_params)
        expect(result).to eq({
          "Any" => [
            {
              "Equal" => [
                { "Property" => ["plan"] },
                "basic"
              ]
            },
            {
              "GreaterThan" => [
                { "Property" => ["user_id"] },
                100
              ]
            }
          ]
        })
      end
    end

    context 'with complex All expression form params' do
      let(:form_params) do
        {
          'complex_expression_type' => 'all',
          'complex_expressions' => {
            '0' => {
              'property_name' => 'plan',
              'operator_class' => 'Equal',
              'value' => 'premium'
            },
            '1' => {
              'property_name' => 'premium',
              'operator_class' => 'Equal',
              'value' => 'true'
            }
          }
        }
      end

      it 'deserializes to complex All expression hash' do
        result = described_class.deserialize(form_params)
        expect(result).to eq({
          "All" => [
            {
              "Equal" => [
                { "Property" => ["plan"] },
                "premium"
              ]
            },
            {
              "Equal" => [
                { "Property" => ["premium"] },
                true
              ]
            }
          ]
        })
      end
    end

    context 'with empty complex expressions' do
      let(:form_params) do
        {
          'complex_expression_type' => 'any',
          'complex_expressions' => {
            '0' => {
              'property' => '',
              'operator' => 'eq',
              'value' => 'basic'
            }
          }
        }
      end

      it 'skips empty expressions' do
        result = described_class.deserialize(form_params)
        expect(result).to eq({
          "Any" => []
        })
      end
    end

    context 'with unknown complex expression type' do
      let(:form_params) do
        {
          'complex_expression_type' => 'unknown',
          'complex_expressions' => {}
        }
      end

      it 'raises an error' do
        expect {
          described_class.deserialize(form_params)
        }.to raise_error("Unknown complex expression type: unknown")
      end
    end

    context 'with unknown operator' do
      let(:form_params) do
        {
          'property_name' => 'plan',
          'operator_class' => 'unknown',
          'value' => 'basic'
        }
      end

      it 'raises an error for unknown operator' do
        expect {
          described_class.deserialize(form_params)
        }.to raise_error(ArgumentError, "Unknown operator: unknown")
      end
    end
  end

  describe 'round-trip serialization' do
    context 'with simple expression' do
      let(:original_expression_hash) do
        {
          "NotEqual" => [
            { "Property" => ["plan"] },
            "basic"
          ]
        }
      end

      it 'preserves expression data through serialize/deserialize cycle' do
        # Create mock expression
        expression = double(:expression, value: original_expression_hash)
        
        # Serialize to form data
        form_data = described_class.serialize(expression)
        
        # Convert form data to form params format
        form_params = {
          'property_name' => form_data[:property],
          'operator_class' => form_data[:operator],
          'value' => form_data[:value]
        }
        
        # Deserialize back to expression hash
        result = described_class.deserialize(form_params)
        
        expect(result).to eq(original_expression_hash)
      end
    end

    context 'with complex Any expression' do
      let(:original_expression_hash) do
        {
          "Any" => [
            {
              "Equal" => [
                { "Property" => ["plan"] },
                "premium"
              ]
            },
            {
              "LessThan" => [
                { "Property" => ["user_id"] },
                50
              ]
            }
          ]
        }
      end

      it 'preserves expression data through serialize/deserialize cycle' do
        # Create mock expression
        expression = double(:expression, value: original_expression_hash)
        
        # Serialize to form data
        form_data = described_class.serialize(expression)
        
        # Convert form data to form params format
        form_params = {
          'complex_expression_type' => form_data[:type],
          'complex_expressions' => {}
        }
        
        form_data[:expressions].each_with_index do |expr, index|
          form_params['complex_expressions'][index.to_s] = {
            'property_name' => expr[:property],
            'operator_class' => expr[:operator],
            'value' => expr[:value]
          }
        end
        
        # Deserialize back to expression hash
        result = described_class.deserialize(form_params)
        
        expect(result).to eq(original_expression_hash)
      end
    end
  end
end
