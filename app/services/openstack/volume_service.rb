module Openstack
  class VolumeService < OpenstackServiceProvider::Service
    
    def get_driver(params)
      auth_params[:connection_options]= { ssl_verify_peer: false }
      Fog::Volume::OpenStack.new(auth_params)
    end
  end
end