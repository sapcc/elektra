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
    
    def available?(action_name_sym=nil)
      not current_user.service_url('image',region: region).nil?  
    end
  
    def images
      driver.map_to(Image::Image).images
    end
  end
end
