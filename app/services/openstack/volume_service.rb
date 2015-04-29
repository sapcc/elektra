module Openstack
  class VolumeService < OpenstackServiceProvider::FogProvider
    
    def driver(auth_params)
      Fog::Volume::OpenStack.new(auth_params)
    end
  end
end