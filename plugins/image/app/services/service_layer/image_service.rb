module ServiceLayer
  class ImageService < Core::ServiceLayer::Service
    def driver
      @driver ||= Image::Driver::Fog.new(
        auth_url:   auth_url,
        region:     region,
        token:      token,
        domain_id:  domain_id,
        project_id: project_id
      )
    end

    def available?(_action_name_sym = nil)
      true #driver.available
    end

    def images(filter = {})
      driver.map_to(Image::Image).images(filter)
    end

    def find_image(id)
      return nil if id.blank?
      driver.map_to(Image::Image).get_image(id)
    end
    
    def add_member_to_image(image_id, tenant_id)
      driver.map_to(Image::Member).add_member_to_image(image_id, tenant_id)
    end
    
    def new_member(attributes={})
      Image::Member.new(driver,attributes)
    end

    def members(id)
      driver.map_to(Image::Member).members(id)
    end
  end
end
