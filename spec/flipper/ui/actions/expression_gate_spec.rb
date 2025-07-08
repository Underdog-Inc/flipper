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
               'expression' => {
                 'type' => 'Equal',
                 'args' => {
                   '0' => {
                     'type' => 'Property',
                     'args' => {
                       '0' => 'plan'
                     }
                   },
                   '1' => 'basic'
                 }
               },
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
                 'expression' => {
                   'type' => 'invalid_op',
                   'args' => {
                     '0' => {
                       'type' => 'Property',
                       'args' => {
                         '0' => 'plan'
                       }
                     },
                     '1' => 'basic'
                   }
                 },
                 'authenticity_token' => token
               },
               'rack.session' => session }.to raise_error(NameError, /wrong constant name invalid_op/)
      end
    end

    ['Equal', 'NotEqual', 'GreaterThan', 'GreaterThanOrEqualTo', 'LessThan', 'LessThanOrEqualTo'].each do |operator|
      context "with #{operator} operator" do
        before do
          flipper.disable :search
          post 'features/search/expression',
               {
                 'operation' => 'enable',
                 'expression' => {
                   'type' => operator,
                   'args' => {
                     '0' => {
                       'type' => 'Property',
                       'args' => {
                         '0' => 'plan'
                       }
                     },
                     '1' => 'basic'
                   }
                 },
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
               'expression' => {
                 'type' => 'Equal',
                 'args' => {
                   '0' => {
                     'type' => 'Property',
                     'args' => {
                       '0' => 'plan'
                     }
                   },
                   '1' => 'basic'
                 }
               },
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
               'expression' => {
                 'type' => 'Any',
                 'args' => {
                   '0' => {
                     'type' => 'Equal',
                     'args' => {
                       '0' => {
                         'type' => 'Property',
                         'args' => {
                           '0' => 'plan'
                         }
                       },
                       '1' => 'basic'
                     }
                   },
                   '1' => {
                     'type' => 'Equal',
                     'args' => {
                       '0' => {
                         'type' => 'Property',
                         'args' => {
                           '0' => 'premium'
                         }
                       },
                       '1' => 'true'
                     }
                   }
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
               'expression' => {
                 'type' => 'All',
                 'args' => {
                   '0' => {
                     'type' => 'Equal',
                     'args' => {
                       '0' => {
                         'type' => 'Property',
                         'args' => {
                           '0' => 'plan'
                         }
                       },
                       '1' => 'premium'
                     }
                   },
                   '1' => {
                     'type' => 'GreaterThanOrEqualTo',
                     'args' => {
                       '0' => {
                         'type' => 'Property',
                         'args' => {
                           '0' => 'age'
                         }
                       },
                       '1' => '18'
                     }
                   }
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
            { "GreaterThanOrEqualTo" => [{ "Property" => ["age"] }, "18"] }
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


end
