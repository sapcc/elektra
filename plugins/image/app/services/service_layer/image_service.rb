module ServiceLayer
  class ImageService < DomainModelServiceLayer::Service
  
    def init(params)
      @driver = Image::Driver::Fog.new(params)
      raise "Error" unless @driver.is_a?(Image::Driver::Interface)
    end
  
    def images
      @driver.map_to(Image::Image).images
    end
  end
end
