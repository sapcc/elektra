module Openstack
  class VolumeService < OpenstackServiceProvider::FogProvider
    
    def driver(auth_params)
      auth_params[:connection_options]= { ssl_verify_peer: false }
      Fog::Volume::OpenStack.new(auth_params)
    end
  end
end