module Openstack
  class ImageService < OpenstackServiceProvider::FogProvider
    
    def driver(auth_params)
      auth_params[:connection_options]= { ssl_verify_peer: false }
      Fog::Image::OpenStack.new(auth_params)
    end
    
  end
end