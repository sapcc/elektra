# frozen_string_literal: true

module ServiceLayerNg
  # implements the LBAAS API
  class LoadbalancingService < Core::ServiceLayerNg::Service
    include LoadbalancingServices::Loadbalancer
    include LoadbalancingServices::Listener
    include LoadbalancingServices::Pool
    include LoadbalancingServices::Healthmonitor
    include LoadbalancingServices::L7Rule

    def available?(_action_name_sym = nil)
      elektron.service?('neutron')
    end

    def elektron_lb
      @elektron_lb ||= elektron(debug: Rails.env.development?).service(
        'neutron', path_prefix: '/v2.0/lbaas'
      )
    end
  end
end
