# frozen_string_literal: true

module ServiceLayerNg
  # Implements Openstack Neutron API
  class NetworkingService < Core::ServiceLayerNg::Service
    include Network
    include Subnet
    include Port
    include FloatingIp
    include SecurityGroup
    include SecurityGroupRule
    include Router
    include Rbac

    def available?(_action_name_sym = nil)
      api.catalog_include_service?('network', region)
    end
  end
end
