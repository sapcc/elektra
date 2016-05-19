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
      driver.available
    end

    def images(filter = {})
      driver.map_to(Image::Image).images(filter)
    end

    def find_image(id)
      return nil if id.blank?
      driver.map_to(Image::Image).get_image(id)
    end
  end
end
