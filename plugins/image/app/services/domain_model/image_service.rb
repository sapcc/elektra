module DomainModel
  class ImageService < DomainModelServiceLayer::Service
  
    def get_driver(params)
      DomainModelServiceLayer::FogDriver::Image.new(params)
    end
  
    def images
      @driver.map_to(Image::Image).images
    end
  end
end
