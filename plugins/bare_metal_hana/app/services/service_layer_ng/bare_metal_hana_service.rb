# frozen_string_literla: true

module ServiceLayerNg
  class BareMetalHanaService < Core::ServiceLayerNg::Service
    def available?(_action_name_sym = nil)
      elektron.service?('ironic')
    end
  end
end
