require 'flipper/ui/action'
require 'flipper/ui/decorators/feature'
require 'flipper/ui/util'
require 'flipper/ui/expression_serializer'

module Flipper
  module UI
    module Actions
      class ExpressionGate < UI::Action
        include FeatureNameFromRoute

        route %r{\A/features/(?<feature_name>.*)/expression/?\Z}

        def post
          render_read_only if read_only?

          feature = flipper[feature_name]

          case params['operation']
          when 'enable'
            expression = Flipper::Expression.build(ExpressionSerializer.deserialize(params))
            feature.enable_expression expression
          when 'disable'
            feature.disable_expression
          end

          redirect_to("/features/#{Flipper::UI::Util.escape feature.key}")
        end

        private
      end
    end
  end
end
