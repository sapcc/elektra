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

    # TODO

  end
end
