module DomainModel
  class ImageService < DomainModelServiceLayer::Service
  
    def get_driver(params)
      driver = Image::Driver::Fog.new(params)
      raise "Error" unless driver.is_a?(Image::Driver::Interface)
      driver
    end
  
    def images
      @driver.map_to(Image::Image).images
    end
  end
end
