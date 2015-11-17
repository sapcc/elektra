module ServiceLayer
  class NetworkingService < DomainModelServiceLayer::Service
  
    def driver
      @driver ||= Networking::Driver::Fog.new({
        auth_url:   self.auth_url,
        region:     self.region,
        token:      self.token,
        domain_id:  self.domain_id,
        project_id: self.project_id  
      })
    end

    def networks(filter={})
      driver..map_to(Networking::Network).networks(filter)  
    end
  
    def project_networks(project_id)
      result = []
      driver.networks.each do |n| 
        if n["shared"]==true or n["tenant_id"]==project_id
          result << Networking::Network.new(driver,n)
        end
      end
      result
    end
  
    def network(id=nil)
      if id
        driver.map_to(Networking::Network).get_network(id)
      else
        Networking::Network.new(driver)
      end
    end
  
    def subnet(id=nil)
      if id
        driver.map_to(Networking::Subnet).get_subnet(id)
      else
        Networking::Subnet.new(driver)
      end
    end
  
    def subnets(network_id)
      driver.map_to(Networking::Subnet).subnets(network_id)
    end
  
    def ports(network_id)
      driver.map_to(Networking::Port).ports(network_id)
    end
  end
end