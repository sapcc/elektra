# frozen_string_literal: true

module ServiceLayer
  # This class implements the cronus api
  class CronusService < Core::ServiceLayer::Service
    def available?(_action_name_sym = nil)
      true
    end

    def test
      elektron.service('cronus').get('/')
    end
  end
end
