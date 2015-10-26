module OpenstackServiceProvider
  module Driver
    # Neutron calls
    class Network < OpenstackServiceProvider::Driver::Base
      ###################### NETWORKS #######################
      def networks(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def get_network(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def create_network(params = {})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def update_network(id, params={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def delete_network(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      ###################### PORTS #######################
      def ports(network_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def get_port(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def create_port(params = {})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def update_port(id,params={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def delete_port(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      ###################### SUBNETS #######################
      def subnets(network_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def get_subnet(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def create_subnet(params = {})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def update_subnet(id, params={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def delete_subnet(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
    end
  end
end