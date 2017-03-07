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

    def project_networks(project_id,filter=nil)
      result = []
      driver.networks(filter).each do |n|
        if n['shared'] == true || n['tenant_id'] == project_id
          result << Networking::Network.new(driver, n)
        end
      end
      result
    end

    def network(id)
      driver.map_to(Networking::Network).get_network(id) if id.present?
    end

    def domain_floatingip_network(domain_name)
      name_candidates = ["FloatingIP-external-#{domain_name}",
      "FloatingIP-internal-#{domain_name}",
      "Converged Cloud External"]
      name_candidates.each do |name|
        network = driver.map_to(Networking::Network).networks("router:external"=>true, "name" => name).first
        return network if network
      end
      return nil
    end

    def new_network(attributes={})
      Networking::Network.new(driver,attributes)
    end

    def subnet(id=nil)
      driver.map_to(Networking::Subnet).get_subnet(id)
    end

    def new_subnet(attributes={})
      Networking::Subnet.new(driver,attributes)
    end

    def subnets(filter)
      driver.map_to(Networking::Subnet).subnets(filter)
    end

    def ports(filter={})
      driver.map_to(Networking::Port).ports(filter)
    end

    def find_port(id)
      driver.map_to(Networking::Port).get_port(id)
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

    def find_floating_ip(id)
      driver.map_to(Networking::FloatingIp).get_floating_ip(id)
    end

    def delete_floating_ip(floating_ip_id)
      driver.delete_floating_ip(floating_ip_id)
    end

    def security_groups(options={})
      driver.map_to(Networking::SecurityGroup).security_groups(options)
    end

    def new_security_group(attributes={})
      Networking::SecurityGroup.new(driver,attributes)
    end

    def find_security_group(id)
      driver.map_to(Networking::SecurityGroup).get_security_group(id)
    end

    def security_group_rules(options={})
      driver.map_to(Networking::SecurityGroupRule).list_security_group_rules(options)
    end

    def find_security_group_rule(security_group_rule_id)
      driver.map_to(Networking::SecurityGroupRule).get_security_group_rule(security_group_rule_id)
    end

    def new_security_group_rule(attributes={})
      Networking::SecurityGroupRule.new(driver,attributes)
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

    def find_rbac(id)
      driver.map_to(Networking::Rbac).get_rbac(id)
    end

    def new_rbac(attributes={})
      Networking::Rbac.new(driver,attributes)
    end
  end
end
