module Networking
  module Driver
    # Compute calls
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper
    
      def initialize(params)
        super(params)
        @fog = ::Fog::Network::OpenStack.new(auth_params)
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
      def subnets(network_id)
        handle_response{
          @fog.list_subnets(network_id: network_id).body['subnets']
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
    end
  end
end