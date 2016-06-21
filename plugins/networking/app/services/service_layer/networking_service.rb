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
      driver.map_to(Networking::Network).networks(filter)
    end

    def project_networks(project_id)
      result = []
      driver.networks.each do |n|
        if n['shared'] == true || n['tenant_id'] == project_id
          result << Networking::Network.new(driver, n)
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

    def subnets(filter)
      driver.map_to(Networking::Subnet).subnets(filter)
    end

    def ports(filter={})
      driver.map_to(Networking::Port).ports(filter)
    end

    def project_floating_ips(project_id,filter={})
      result = []
      driver.floating_ips(filter).each do |fip|
        if fip['tenant_id'] == project_id
          result << Networking::FloatingIp.new(driver, fip)
        end
      end
      result
    end
    
    def attach_floatingip(floating_ip_id, port_id, options = {})
      driver.map_to(Networking::FloatingIp).associate_floating_ip(floating_ip_id,port_id,options)
    end

    def detach_floatingip(floating_ip_id)
      driver.map_to(Networking::FloatingIp).disassociate_floating_ip(floating_ip_id)
    end
    
    def new_floating_ip(params={})
      Networking::FloatingIp.new(driver,params)
    end
    
    def delete_floating_ip(floating_ip_id)
      driver.delete_floating_ip(floating_ip_id)
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

    ####################### ROUTERS #############################
    def routers(filter={})
      driver.map_to(Networking::Router).routers(filter)
    end

    def find_router(id)
      driver.map_to(Networking::Router).get_router(id)
    end

    def new_router(params={})
      Networking::Router.new(driver,params)
    end

    def add_router_interfaces(router_id,interface_ids)
      interface_ids.each do |interface_id|
        driver.add_router_interface(router_id, interface_id)
      end
    end

    def remove_router_interfaces(router_id, interface_ids,options={})
      interface_ids.each do |interface_id|
        driver.remove_router_interface(router_id, interface_id,options)
      end
    end

    ####################### PORTS #############################
    # def ports(filter={})
    #   driver.map_to(Networking::Router).routers(filter)
    # end
    #
    # def find_router(id)
    #   driver.map_to(Networking::Router).get_router(id)
    # end

    ####################### RBACS #############################
    def rbacs(filter = {})
      driver.map_to(Networking::Rbac).rbacs(filter)
    end

    def rbac(id = nil)
      if id
        driver.map_to(Networking::Rbac).get_rbac(id)
      else
        Networking::Rbac.new(driver)
      end
    end
  end
end
