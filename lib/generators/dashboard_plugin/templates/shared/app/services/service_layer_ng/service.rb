# frozen_string_literal: true

module ServiceLayerNg
  # This class implements the %{PLUGIN_NAME} api
  class %{PLUGIN_NAME_CAMELIZE}Service < Core::ServiceLayerNg::Service
    def available?(_action_name_sym = nil)
      true
    end

    def test
      api.%{PLUGIN_NAME}.requests
    end
  end
end
