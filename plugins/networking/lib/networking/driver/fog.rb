module Networking
  module Driver
    # Compute calls
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper
      attr_reader :available

      def initialize(params)
        super(params)
        @fog = ::Fog::Network::OpenStack.new(auth_params)
        @available = true
      rescue ::Fog::OpenStack::Errors::ServiceUnavailable
        @fog = nil
        @available = false
      end

      ########################### NETWORKS #############################
      def networks(filter={})
        handle_response{
          @fog.list_networks(filter).body['networks']
        }
      end

      def get_network(id)
        handle_response{
          @fog.get_network(id).body['network']
        }
      end

      def create_network(params = {})
        handle_response{
          @fog.create_network(params).body['network']
        }
      end

      def update_network(id, params={})
        handle_response{
          @fog.update_network(id, params).body['network']
        }
      end

      def delete_network(id)
        handle_response{
          @fog.delete_network(id)
          true
        }
      end

      ###################### PORTS #######################
      def ports(network_id)
        handle_response{
          @fog.list_ports(network_id: network_id).body['ports']
        }
      end

      def get_port(id)
        handle_response{ @fog.get_port(id).body['port']}
      end

      def create_port(params = {})
        handle_response{
          network_id = params.delete("network_id")
          @fog.create_port(network_id, params).body['port']
        }
      end

      def update_port(id, params={})
        handle_response{ @fog.update_port(id,params).body['port']}
      end

      def delete_port(id)
        handle_response{
          @fog.delete_port(id)
          true
        }
      end

      ###################### SUBNETS #######################
      def subnets(filter={})
        handle_response{
          @fog.list_subnets(filter).body['subnets']
        }
      end

      def get_subnet(id)
        handle_response{ @fog.get_subnet(id).body['subnet']}
      end

      def create_subnet(params = {})
        handle_response{
          network_id = params.delete("network_id")
          cidr = params.delete("cidr")
          ip_version = params.delete("ip_version")
          @fog.create_subnet(network_id, cidr, ip_version, params).body['subnet']
        }
      end

      def update_subnet(id, params={})
        handle_response{
          @fog.update_subnet(id,params).body['subnet']
        }
      end

      def delete_subnet(id)
        handle_response{
          @fog.delete_subnet(id)
          true
        }
      end

      ###################### FLOATING IPS #######################
      def floating_ips(filter = {})
        handle_response { @fog.list_floating_ips(filter).body['floatingips'] }
      end
      
      def get_floating_ip(id)
        handle_response{@fog.get_floating_ip(id).body['floatingip']}
      end
      
      def create_floating_ip(params)
        network_id = params.delete(:floating_network_id)
        handle_response{@fog.create_floating_ip(network_id, params).body['floatingip']}
      end
      
      def delete_floating_ip(floating_ip_id)
        handle_response{@fog.delete_floating_ip(floating_ip_id)}
      end
      
      def associate_floating_ip(floating_ip_id, port_id, options = {})
        handle_response{@fog.associate_floating_ip(floating_ip_id, port_id, options).body['floatingip']}
      end
      
      def disassociate_floating_ip(floating_ip_id, options = {})
        handle_response{@fog.disassociate_floating_ip(floating_ip_id, options).body['floatingip']}
      end

      ###################### SECURITY GROUPS #######################
      def security_groups(filter = {})
        handle_response { @fog.list_security_groups(filter).body['security_groups'] }
      end

      ###################### ROUTERS ####################
      def routers(filter={})
        handle_response { @fog.list_routers(filter).body['routers']}
      end

      def add_router_interface(router_id, subnet_id_or_options)
        handle_response { @fog.add_router_interface(router_id, subnet_id_or_options)}
      end

      def remove_router_interface(router_id, subnet_id, options = {})
        handle_response{ @fog.remove_router_interface(router_id, subnet_id, options)}
      end

      def get_router(router_id)
        handle_response { @fog.get_router(router_id).body['router']}
      end

      def create_router(params)
        name = params.delete("name")
        handle_response { @fog.create_router(name, params).body['router'] }
      end

      def update_router(id,params)
        handle_response { @fog.update_router(id, params).body['router'] }
      end

      def delete_router(id)
        handle_response{@fog.delete_router(id)}
      end

      ###################### PORTS ####################
      def ports(filter={})
        handle_response { @fog.list_ports(filter).body['ports']}
      end

      def get_port(id)
        handle_response { @fog.get_port(id).body['port']}
      end

      def create_port(network_id,params)
        handle_response { @fog.create_port(network_id, params).body['port'] }
      end

      def update_port(id,params)
        handle_response { @fog.update_port(id, params).body['port'] }
      end

      def delete_port(id)
        handle_response{@fog.delete_port(id)}
      end

      ###################### RBACS ####################
      def rbacs(filter = {})
        handle_response { @fog.list_rbac_policies(filter).body['rbac_policies'] }
      end

      def get_rbac(id)
        handle_response { @fog.get_rbac_policy(id).body['rbac_policy'] }
      end

      def create_rbac(params)
        handle_response { @fog.create_rbac_policy(params).body['rbac_policy'] }
      end

      def delete_rbac(id)
        handle_response { @fog.delete_rbac_policy(id) }
      end
    end
  end
end
