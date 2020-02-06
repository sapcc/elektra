# frozen_string_literal: true

module ServiceLayer
  # implements the LBAAS API
  class LbaasService < Core::ServiceLayer::Service
    include LbaasServices::Loadbalancer
    include LbaasServices::Listener
    include LbaasServices::Pool
    include LbaasServices::PoolMember
    include LbaasServices::Healthmonitor
    include LbaasServices::L7policy
    include LbaasServices::L7rule

    def available?(_action_name_sym = nil)
      elektron.service?('octavia')
    end

    def elektron_lb
      @elektron_lb ||= elektron.service('octavia', path_prefix: '/v2.0/lbaas')
    end
  end
end
