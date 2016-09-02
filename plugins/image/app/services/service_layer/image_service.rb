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
    
    def remove_member_from_image(image_id,member_id)
      driver.remove_member_from_image(image_id, member_id)
    end
    
    def new_member(attributes={})
      Image::Member.new(driver,attributes)
    end

    def members(id)
      driver.map_to(Image::Member).members(id)
    end
    
    def accept_member(member)
      return false if member.nil?
      driver.map_to(Image::Member).update_image_member(member.image_id,member.member_id,'accepted')
    end
    
    def reject_member(member)
      return false if member.nil?
      driver.map_to(Image::Member).update_image_member(member.image_id,member.member_id,'rejected')
    end
    
    def publish_image(id)
      driver.map_to(Image::Image).update_image_values(id, [ { 
        op: "replace", 
        path: "/visibility", 
        value: "public"
      }])
    end
    
    def unpublish_image(id)
      driver.map_to(Image::Image).update_image_values(id, [ { 
        op: "replace", 
        path: "/visibility", 
        value: "private"
      }])      
    end
  end
end
