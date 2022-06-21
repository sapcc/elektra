# frozen_string_literal: true

module ServiceLayer
  # This class implements the %{PLUGIN_NAME} api
  class %{PLUGIN_NAME_CAMELIZE}Service < Core::ServiceLayer::Service
    def available?(_action_name_sym = nil)
      true
    end

    def test
      elektron.service('%{PLUGIN_NAME}').get('/')
    end
  end
end
