# frozen_string_literal: true

module ServiceLayerNg

  class %{PLUGIN_NAME}Service < Core::ServiceLayerNg::Service

    def available?(action_name_sym=nil)
      true
    end

    def test
      api.%{PLUGIN_NAME}.requests
    end
  end
end
