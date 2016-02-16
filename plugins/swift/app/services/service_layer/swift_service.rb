module ServiceLayer

  class SwiftService < DomainModelServiceLayer::Service

    def driver
      @driver ||= Swift::Driver::Fog.new({
        auth_url:   self.auth_url,
        region:     self.region,
        token:      self.token,
        domain_id:  self.domain_id,
        project_id: self.project_id,
      })
    end

    def available?(action_name_sym=nil)
      not current_user.service_url('object-store',region: region).nil?
    end

    ##### containers

    def find_container(name)
      name.blank? ? nil : driver.map_to(Swift::Container).get_container(name)
    end

    def containers(filter={})
      driver.map_to(Swift::Container).containers(filter)
    end

    def new_container(attributes={})
      Swift::Container.new(@driver, attributes)
    end

    ##### objects

    def find_object(container_name, path)
      return nil if container_name.blank? or path.blank?
      return driver.map_to(Swift::Object).get_object(container_name, path)
    end

    def list_objects_at_path(container_name, path)
      return [] if container_name.blank?
      return driver.map_to(Swift::Object).objects_at_path(container_name, path)
    end

  end
end
