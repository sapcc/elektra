# frozen_string_literla: true

module ServiceLayer
  class BareMetalHanaService < Core::ServiceLayer::Service
    def available?(_action_name_sym = nil)
      elektron.service?('ironic')
    end
  end
end
