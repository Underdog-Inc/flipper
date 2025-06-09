RSpec.describe Flipper::UI::Actions::ExpressionGate do
  let(:token) do
    if Rack::Protection::AuthenticityToken.respond_to?(:random_token)
      Rack::Protection::AuthenticityToken.random_token
    else
      'a'
    end
  end
  let(:session) do
    { :csrf => token, 'csrf' => token, '_csrf_token' => token }
  end

  describe 'POST /features/:feature/expression' do
    context 'with enable operation' do
      before do
        flipper.disable :search
        post 'features/search/expression',
             {
               'operation' => 'enable',
               'property_name' => 'plan',
               'operator_class' => 'Equal',
               'value' => 'basic',
               'authenticity_token' => token
             },
             'rack.session' => session
      end

      it 'enables the feature with expression' do
        expect(flipper.feature(:search).enabled_gate_names).to include(:expression)
      end

      it 'sets the correct expression' do
        expected_expression = { "Equal" => [{ "Property" => ["plan"] }, "basic"] }
        expect(flipper.feature(:search).expression.value).to eq(expected_expression)
      end

      it 'redirects back to feature' do
        expect(last_response.status).to be(302)
        expect(last_response.headers['location']).to eq('/features/search')
      end
    end

    context 'with disable operation' do
      before do
        expression = Flipper::Expression.build({ "Equal" => [{ "Property" => ["plan"] }, "basic"] })
        flipper.enable_expression :search, expression
        post 'features/search/expression',
             {
               'operation' => 'disable',
               'authenticity_token' => token
             },
             'rack.session' => session
      end

      it 'disables the expression gate' do
        expect(flipper.feature(:search).enabled_gate_names).not_to include(:expression)
      end

      it 'redirects back to feature' do
        expect(last_response.status).to be(302)
        expect(last_response.headers['location']).to eq('/features/search')
      end
    end

    context 'with invalid expression that causes exception' do
      it 'lets exception bubble up' do
        flipper.disable :search
        expect { post 'features/search/expression',
               {
                 'operation' => 'enable',
                 'property_name' => 'plan',
                 'operator_class' => 'invalid_op',
                 'value' => 'basic',
                 'authenticity_token' => token
               },
               'rack.session' => session }.to raise_error(ArgumentError, /Unknown operator: invalid_op/)
      end
    end

    ['Equal', 'NotEqual', 'GreaterThan', 'GreaterThanOrEqualTo', 'LessThan', 'LessThanOrEqualTo'].each do |operator|
      context "with #{operator} operator" do
        before do
          flipper.disable :search
          post 'features/search/expression',
               {
                 'operation' => 'enable',
                 'property_name' => 'plan',
                 'operator_class' => operator,
                 'value' => 'basic',
                 'authenticity_token' => token
               },
               'rack.session' => session
        end

        it 'successfully creates expression' do
          expect(flipper.feature(:search).enabled_gate_names).to include(:expression)
        end

        it 'redirects back to feature' do
          expect(last_response.status).to be(302)
          expect(last_response.headers['location']).to eq('/features/search')
        end
      end
    end

    context 'with space in feature name' do
      before do
        flipper.disable "sp ace"
        post 'features/sp%20ace/expression',
             {
               'operation' => 'enable',
               'property_name' => 'plan',
               'operator_class' => 'Equal',
               'value' => 'basic',
               'authenticity_token' => token
             },
             'rack.session' => session
      end

      it 'enables the feature with expression' do
        expect(flipper.feature("sp ace").enabled_gate_names).to include(:expression)
      end

      it 'redirects back to feature' do
        expect(last_response.status).to be(302)
        expect(last_response.headers['location']).to eq('/features/sp+ace')
      end
    end

    context 'with complex any expression' do
      before do
        flipper.disable :search
        post 'features/search/expression',
             {
               'operation' => 'enable',
               'complex_expression_type' => 'any',
               'complex_expressions' => {
                 '0' => {
                   'property_name' => 'plan',
                   'operator_class' => 'Equal',
                   'value' => 'basic'
                 },
                 '1' => {
                   'property_name' => 'premium',
                   'operator_class' => 'Equal',
                   'value' => 'true'
                 }
               },
               'authenticity_token' => token
             },
             'rack.session' => session
      end

      it 'enables the feature with any expression' do
        expect(flipper.feature(:search).enabled_gate_names).to include(:expression)
      end

      it 'sets the correct any expression' do
        expected_expression = {
          "Any" => [
            { "Equal" => [{ "Property" => ["plan"] }, "basic"] },
            { "Equal" => [{ "Property" => ["premium"] }, "true"] }
          ]
        }
        expect(flipper.feature(:search).expression.value).to eq(expected_expression)
      end

      it 'redirects back to feature' do
        expect(last_response.status).to be(302)
        expect(last_response.headers['location']).to eq('/features/search')
      end
    end

    context 'with complex all expression' do
      before do
        allow(Flipper::UI.configuration).to receive(:expression_properties).and_return({
          'age' => { type: 'number' },
          'premium' => { type: 'boolean' },
          'plan' => { type: 'string' }
        })
        flipper.disable :search
        post 'features/search/expression',
             {
               'operation' => 'enable',
               'complex_expression_type' => 'all',
               'complex_expressions' => {
                 '0' => {
                   'property_name' => 'plan',
                   'operator_class' => 'Equal',
                   'value' => 'premium'
                 },
                 '1' => {
                 'property_name' => 'age',
                 'operator_class' => 'GreaterThanOrEqualTo',
                 'value' => '18'
                 }
               },
               'authenticity_token' => token
             },
             'rack.session' => session
      end

      it 'enables the feature with all expression' do
        expect(flipper.feature(:search).enabled_gate_names).to include(:expression)
      end

      it 'sets the correct all expression' do
        expected_expression = {
          "All" => [
            { "Equal" => [{ "Property" => ["plan"] }, "premium"] },
            { "GreaterThanOrEqualTo" => [{ "Property" => ["age"] }, 18] }
          ]
        }
        expect(flipper.feature(:search).expression.value).to eq(expected_expression)
      end

      it 'redirects back to feature' do
        expect(last_response.status).to be(302)
        expect(last_response.headers['location']).to eq('/features/search')
      end
    end
  end

  describe 'expression parameter parsing using ExpressionSerializer' do
    before do
      allow(Flipper::UI.configuration).to receive(:expression_properties).and_return({
        'age' => { type: 'number' },
        'premium' => { type: 'boolean' },
        'plan' => { type: 'string' }
      })
    end

    it 'supports all comparison operators' do
      operators = {
        'Equal' => 'Equal',
        'NotEqual' => 'NotEqual',
        'GreaterThan' => 'GreaterThan',
        'GreaterThanOrEqualTo' => 'GreaterThanOrEqualTo',
        'LessThan' => 'LessThan',
        'LessThanOrEqualTo' => 'LessThanOrEqualTo'
      }

      operators.each do |op, expression_type|
        params = {
          'property_name' => 'age',
          'operator_class' => op,
          'value' => '25'
        }

        result = Flipper::UI::ExpressionSerializer.deserialize(params)
        expect(result).to eq({
          expression_type => [{ "Property" => ["age"] }, 25]
        })
      end
    end

    it 'converts numeric values' do
      params = {
        'property_name' => 'age',
        'operator_class' => 'GreaterThan',
        'value' => '25'
      }

      result = Flipper::UI::ExpressionSerializer.deserialize(params)
      expect(result['GreaterThan'][1]).to eq(25)
    end

    it 'converts boolean values' do
      params = {
        'property_name' => 'premium',
        'operator_class' => 'Equal',
        'value' => 'true'
      }

      result = Flipper::UI::ExpressionSerializer.deserialize(params)
      expect(result['Equal'][1]).to eq(true)
    end

    it 'handles string values' do
      params = {
        'property_name' => 'plan',
        'operator_class' => 'Equal',
        'value' => 'basic'
      }

      result = Flipper::UI::ExpressionSerializer.deserialize(params)
      expect(result['Equal'][1]).to eq('basic')
    end

    it 'parses complex any expressions' do
      params = {
        'complex_expression_type' => 'any',
        'complex_expressions' => {
          '0' => {
            'property_name' => 'plan',
            'operator_class' => 'Equal',
            'value' => 'basic'
          },
          '1' => {
            'property_name' => 'premium',
            'operator_class' => 'Equal',
            'value' => 'true'
          }
        }
      }

      result = Flipper::UI::ExpressionSerializer.deserialize(params)
      expect(result).to eq({
        "Any" => [
          { "Equal" => [{ "Property" => ["plan"] }, "basic"] },
          { "Equal" => [{ "Property" => ["premium"] }, true] }
        ]
      })
    end

    it 'parses complex all expressions' do
      params = {
        'complex_expression_type' => 'all',
        'complex_expressions' => {
          '0' => {
            'property_name' => 'age',
            'operator_class' => 'GreaterThanOrEqualTo',
            'value' => '18'
          },
          '1' => {
            'property_name' => 'plan',
            'operator_class' => 'NotEqual',
            'value' => 'free'
          }
        }
      }

      result = Flipper::UI::ExpressionSerializer.deserialize(params)
      expect(result).to eq({
        "All" => [
          { "GreaterThanOrEqualTo" => [{ "Property" => ["age"] }, 18] },
          { "NotEqual" => [{ "Property" => ["plan"] }, "free"] }
        ]
      })
    end

    it 'skips empty expressions in complex forms' do
      params = {
        'complex_expression_type' => 'any',
        'complex_expressions' => {
          '0' => {
            'property_name' => 'plan',
            'operator_class' => 'Equal',
            'value' => 'basic'
          },
          '1' => {
            'property_name' => '',
            'operator_class' => 'Equal',
            'value' => 'something'
          },
          '2' => {
            'property_name' => 'premium',
            'operator_class' => '',
            'value' => 'true'
          }
        }
      }

      result = Flipper::UI::ExpressionSerializer.deserialize(params)
      expect(result).to eq({
        "Any" => [
          { "Equal" => [{ "Property" => ["plan"] }, "basic"] }
        ]
      })
    end

    it 'raises error for unknown complex expression type' do
      params = {
        'complex_expression_type' => 'unknown',
        'complex_expressions' => {}
      }

      expect { Flipper::UI::ExpressionSerializer.deserialize(params) }.to raise_error('Unknown complex expression type: unknown')
    end
  end
end
