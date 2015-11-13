module ServiceLayer
  class ImageService < DomainModelServiceLayer::Service
  
    def driver
      @driver ||= Image::Driver::Fog.new({
        auth_url:   self.auth_url,
        region:     self.region,
        token:      self.token,
        domain_id:  self.domain_id,
        project_id: self.project_id  
      })
    end
  
    def images
      driver.map_to(Image::Image).images
    end
  end
end
