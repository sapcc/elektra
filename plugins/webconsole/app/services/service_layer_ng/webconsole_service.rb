# frozen_string_literal: true

module ServiceLayerNg
  # webconsole
  class WebconsoleService < Core::ServiceLayerNg::Service
    def available?(_action_name_sym = nil)
      elektron.service?('webcli') && elektron.service?('identity')
    end
  end
end
