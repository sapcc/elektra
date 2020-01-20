# frozen_string_literal: true

module ServiceLayer
  # implements the LBAAS API
  class Lbaas2Service < Core::ServiceLayer::Service
    include Lbaas2Services::Loadbalancer

    def available?(_action_name_sym = nil)
      elektron.service?('octavia')
    end

    def elektron_lb
      @elektron_lb ||= elektron.service('octavia', path_prefix: '/v2.0/lbaas')
    end
  end
end
