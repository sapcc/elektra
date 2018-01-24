# frozen_string_literal: true

module Networking
  # Implements Openstack Port
  class Port < Core::ServiceLayer::Model
    DEVICE_OWNER_INSTANCE = 'instance'
    DEVICE_OWNER_LOADBALANCER = 'loadbalancer'

    DEVICE_OWNER_MAP = {
      'compute:' => DEVICE_OWNER_INSTANCE,
      'neutron:LOADBALANCER' => DEVICE_OWNER_LOADBALANCER
    }.freeze

    def network_object
      @network_object ||= @service.find_network(network_id)
    end

    def owner_type
      DEVICE_OWNER_MAP.each do |key, type|
        return type if device_owner.to_s.start_with?(key)
      end
      'unknown'
    end
  end
end
