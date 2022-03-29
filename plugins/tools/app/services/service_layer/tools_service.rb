# frozen_string_literal: true

module ServiceLayer
  class ToolsService < Core::ServiceLayer::Service

    def available?(_action_name_sym = nil)
      true
    end

    def has_castellum?
      elektron.service?('castellum')
    end

    def has_limes?
      elektron.service?('resources')
    end

  end
end
