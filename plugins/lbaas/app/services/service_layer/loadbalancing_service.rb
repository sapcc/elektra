# frozen_string_literal: true

module ServiceLayer
  # implements the LBAAS API
  class LoadbalancingService < Core::ServiceLayer::Service
    include LoadbalancingServices::Loadbalancer
    include LoadbalancingServices::Listener
    include LoadbalancingServices::Pool
    include LoadbalancingServices::PoolMember
    include LoadbalancingServices::Healthmonitor
    include LoadbalancingServices::L7policy
    include LoadbalancingServices::L7rule

    def available?(_action_name_sym = nil)
      elektron.service?('neutron')
    end

    def elektron_lb
      @elektron_lb ||= elektron.service('neutron', path_prefix: '/v2.0/lbaas')
    end
  end
end
