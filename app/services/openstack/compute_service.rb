module Openstack
  class ComputeService < OpenstackServiceProvider::FogProvider
    
    def driver(auth_params)
      Fog::Compute::OpenStack.new(auth_params)
    end
  end
end