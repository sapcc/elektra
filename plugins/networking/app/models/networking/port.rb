module Networking
  class Port < Core::ServiceLayer::Model
    DEVICE_OWNER_INSTANCE = 'instance'
    DEVICE_OWNER_LOADBALANCER = 'loadbalancer'
    
    DEVICE_OWNER_MAP = {
      'compute:' => DEVICE_OWNER_INSTANCE,
      'neutron:LOADBALANCER' => DEVICE_OWNER_LOADBALANCER,
    }
    
    def network_object
      @network_object ||= @driver.map_to(::Networking::Network).get_network(self.network_id)
    end
    
    def owner_type
      DEVICE_OWNER_MAP.each do |key, type|
        return type if self.device_owner.to_s.start_with?(key)
      end
      return 'unknown'
    end    
  end
end