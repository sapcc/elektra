# frozen_string_literal: true

module ServiceLayer
  # implements the LBAAS API
  class Lbaas2Service < Core::ServiceLayer::Service
    include Lbaas2Services::Loadbalancer
    include Lbaas2Services::Listener
    include Lbaas2Services::Pool

    def available?(_action_name_sym = nil)
      elektron.service?('octavia')
    end

    def elektron_lb2
      @elektron_lb2 ||= elektron.service('octavia', path_prefix: '/v2.0/lbaas')
    end
  end
end
