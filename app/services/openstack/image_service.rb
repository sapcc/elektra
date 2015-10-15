module Openstack
  class ImageService < OpenstackServiceProvider::Service
    
    def get_driver(params)
      OpenstackServiceProvider::FogDriver::Image.new(params)
    end
    
    def images
      @driver.map_to(Image::Image).images
    end
  end
end