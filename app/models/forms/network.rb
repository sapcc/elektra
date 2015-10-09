require 'fog/openstack/models/compute/server'

class Forms::Network < Forms::Base
  # available attributes: 
  # :name
  # :subnets
  # :shared
  # :status
  # :admin_state_up
  # :tenant_id
  # :provider_network_type
  # :provider_physical_network
  # :provider_segmentation_id
  # :router_external
    
  wrapper_for ::Fog::Compute::OpenStack::Network
     
end
