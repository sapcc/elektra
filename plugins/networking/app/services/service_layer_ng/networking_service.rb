# frozen_string_literal: true

module ServiceLayerNg
  # Implements Openstack Neutron API
  class NetworkingService < Core::ServiceLayerNg::Service

    def network_ip_availability(network_id)
      api.networking.show_network_ip_availability(network_id)
         .map_to(Networking::NetworkIpAvailabilityNg)
    end

    def network_ip_availabilities
      api.networking.list_network_ip_availability
         .map_to(Networking::NetworkIpAvailabilityNg)
    end

    def available?(_action_name_sym = nil)
      api.catalog_include_service?('network', region)
    end

    def networks(filter = {})
      api.networking.list_networks(filter).map_to(Networking::NetworkNg)
    end

    def project_networks(project_id, filter = nil)
      api.networking.networks(filter).data.each_with_object([]) do |n, array|
        if n['shared'] == true || n['tenant_id'] == project_id
          array << map_to(Networking::NetworkNg, n)
        end
      end
    end

    def find_network!(id)
      return nil unless id
      api.networking.show_network_details(id).map_to(Networking::NetworkNg)
    end

    def find_network(id)
      find_network!(id)
    rescue
      nil
    end

    def domain_floatingip_network(domain_name)
      # ccadmin, cc3test -> FloatingIP-internal-monsoon3
      domain_name = 'monsoon3' if %w[ccadmin cc3test].include?(domain_name)

      name_candidates = ["FloatingIP-external-#{domain_name}",
                         "FloatingIP-internal-#{domain_name}",
                         'Converged Cloud External']
      name_candidates.each do |name|
        network = api.networking.list_networks(
          'router:external' => true, 'name' => name
        ).map_to(Networking::NetworkNg).first
        return network if network
      end
      nil
    end

    def new_network(attributes = {})
      map_to(Networking::NetworkNg, attributes)
    end

    def find_subnet!(id)
      return nil unless id
      api.networking.show_subnet_details(id).map_to(Networking::SubnetNg)
    end

    def find_subnet(id)
      find_subnet!(id)
    rescue
      nil
    end

    def new_subnet(attributes = {})
      map_to(Networking::SubnetNg, attributes)
    end

    def subnets(filter = {})
      api.networking.list_subnets(filter).map_to(Networking::SubnetNg)
    end

    def ports(filter = {})
      api.networking.list_ports(filter).map_to(Networking::PortNg)
    end

    def find_port!(id)
      return nil unless id
      api.networking.show_port_details(id).map_to(Networking::PortNg)
    end

    def find_port(id)
      find_port!(id)
    rescue
      nil
    end

    def project_floating_ips(project_id, filter = {})
      api.networking
         .list_floating_ips(filter)
         .data
         .each_with_object([]) do |ip, array|
           if ip['tenant_id'] == project_id
             array << map_to(Networking::FloatingIpNg, fip)
           end
         end
    end

    def attach_floatingip(floating_ip_id, port_id)
      api.networking.update_floating_ip(
        floating_ip_id, floatingip: { port_id: port_id }
      ).map_to(Networking::FloatingIpNg)
    end

    def detach_floatingip(floating_ip_id)
      api.networking.update_floating_ip(
        floating_ip_id, floatingip: { port_id: nil }
      ).map_to(Networking::FloatingIpNg)
    end

    def new_floating_ip(attributes = {})
      map_to(Networking::FloatingIpNg, attributes)
    end

    def find_floating_ip!(id)
      return nil unless id
      api.networking.show_floating_ip_details(id)
         .map_to(Networking::FloatingIpNg)
    end

    def find_floating_ip(id)
      find_floating_ip!(id)
    rescue
      nil
    end

    def delete_floating_ip(id)
      api.networking.delete_floating_ip(id)
    end

    def security_groups(filter = {})
      api.networking.list_security_groups(filter)
         .map_to(Networking::SecurityGroupNg)
    end

    def new_security_group(attributes = {})
      map_to(Networking::SecurityGroupNg, attributes)
    end

    def find_security_group!(id)
      return nil unless id
      api.networking.show_security_group(id).map_to(Networking::SecurityGroupNg)
    end

    def find_security_group(id)
      find_security_group!(id)
    rescue
      nil
    end

    def security_group_rules(filter = {})
      api.networking.list_security_group_rules(filter)
         .map_to(Networking::SecurityGroupRuleNg)
    end

    def find_security_group_rule!(id)
      return nil unless id
      api.networking.show_security_group_rule(id)
         .map_to(Networking::SecurityGroupRuleNg)
    end

    def find_security_group_rule(id)
      find_security_group_rule!(id)
    rescue
      nil
    end

    def new_security_group_rule(attributes = {})
      map_to(Networking::SecurityGroupRuleNg, attributes)
    end

    ####################### ROUTERS #############################
    def routers(filter = {})
      api.networking.list_routers(filter).map_to(Networking::RouterNg)
    end

    def find_router!(id)
      return nil unless id
      api.networking.show_router_details(id).map_to(Networking::RouterNg)
    end

    def find_router(id)
      find_router!(id).map_to(Networking::RouterNg)
    rescue
      nil
    end

    def new_router(attributes = {})
      map_to(Networking::RouterNg, attributes)
    end

    def add_router_interfaces(router_id,interface_ids)
      interface_ids.each do |interface_id|
        api.networking.add_interface_to_router(
          router_id, subnet_id: interface_id
        )
      end
    end

    def remove_router_interfaces(router_id, interface_ids)
      interface_ids.each do |interface_id|
        api.networking.remove_interface_from_router(
          router_id, subnet_id: interface_id
        )
      end
    end

    ####################### RBACS #############################
    def rbacs(filter = {})
      api.networking.list_rbac_policies(filter).map_to(Networking::RbacNg)
    end

    def find_rbac!(id)
      return nil unless id
      api.networking.show_rbac_policy_details(id).map_to(Networking::RbacNg)
    end

    def find_rbac(id)
      find_rbac!(id)
    rescue
      nil
    end

    def new_rbac(attributes = {})
      map_to(Networking::Rbac, attributes)
    end
  end
end
