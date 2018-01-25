# frozen_string_literal: true

module ServiceLayer

  class %{PLUGIN_NAME}Service < Core::ServiceLayer::Service

    def available?(action_name_sym=nil)
      true
    end

    def test
      elektron.service('%{PLUGIN_NAME}').get('/')
    end
  end
end
