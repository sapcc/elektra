module Openstack
  class ImageService < OpenstackServiceProvider::FogProvider
    
    def driver(auth_params)
      Fog::Image::OpenStack.new(auth_params)
    end
    
  end
end