module ServiceLayer
  class ComputeService < DomainModelServiceLayer::Service
    
    def driver
      @driver ||= Compute::Driver::Fog.new({
        auth_url:   self.auth_url,
        region:     self.region,
        token:      self.token,
        domain_id:  self.domain_id,
        project_id: self.project_id  
      })
    end
    
    ##################### CREDENTIALS #########################
    def find_server(id)
      driver.map_to(Compute::Server).get_server(id)
    end
    
    def new_server(params={})
      Compute::Server.new(driver,params)
    end
    
    def servers(filter={})
      driver.map_to(Compute::Server).servers(filter)
    end
    
    def images
      driver.map_to(Compute::Image).images
    end
    
    def image(id)
      driver.map_to(Compute::Image).get_image(id)
    end
    
    def flavors
      driver.map_to(Compute::Flavor).flavors
    end
    
    def flavor(id)
      driver.map_to(Compute::Flavor).get_flavor(id)
    end
    
    def availability_zones
      driver.map_to(Compute::AvailabilityZone).availability_zones
    end
    
    def security_groups
      driver.map_to(Compute::SecurityGroup).security_groups
    end

  end
end