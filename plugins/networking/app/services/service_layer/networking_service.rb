module ServiceLayer
  class NetworkingService < Core::ServiceLayer::Service

    def driver
      @driver ||= Networking::Driver::Fog.new({
        auth_url:   self.auth_url,
        region:     self.region,
        token:      self.token,
        domain_id:  self.domain_id,
        project_id: self.project_id
      })
    end

    def available?(_action_name_sym = nil)
      driver.available
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

    def project_floating_ips(project_id)
      result = []
      driver.floating_ips.each do |fip|
        if fip['tenant_id'] == project_id
          result << Networking::FloatingIp.new(driver, fip)
        end
      end
      result
    end

    def project_security_groups(project_id)
      result = []
      driver.security_groups.each do |sg|
        if sg['tenant_id'] == project_id
          result << Networking::SecurityGroup.new(driver, sg)
        end
      end
      result
    end
  end
end
