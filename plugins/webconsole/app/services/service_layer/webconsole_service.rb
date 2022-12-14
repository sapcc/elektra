# frozen_string_literal: true

module ServiceLayer
  # webconsole
  class WebconsoleService < Core::ServiceLayer::Service
    def available?(_action_name_sym = nil)
      elektron.service?("webcli") && elektron.service?("identity")
    end
  end
end
