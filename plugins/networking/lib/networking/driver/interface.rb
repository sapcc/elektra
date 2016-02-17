module Networking
  module Driver
    # Neutron calls
    class Interface < Core::ServiceLayer::Driver::Base
      ###################### NETWORKS #######################
      def networks(filter={})
        raise ServiceLayer::Errors::NotImplemented
      end
    
      def get_network(id)
        raise ServiceLayer::Errors::NotImplemented
      end
    
      def create_network(params = {})
        raise ServiceLayer::Errors::NotImplemented
      end

      def update_network(id, params={})
        raise ServiceLayer::Errors::NotImplemented
      end
    
      def delete_network(id)
        raise ServiceLayer::Errors::NotImplemented
      end
    
      ###################### PORTS #######################
      def ports(network_id)
        raise ServiceLayer::Errors::NotImplemented
      end
    
      def get_port(id)
        raise ServiceLayer::Errors::NotImplemented
      end
    
      def create_port(params = {})
        raise ServiceLayer::Errors::NotImplemented
      end

      def update_port(id,params={})
        raise ServiceLayer::Errors::NotImplemented
      end
    
      def delete_port(id)
        raise ServiceLayer::Errors::NotImplemented
      end
    
      ###################### SUBNETS #######################
      def subnets(network_id)
        raise ServiceLayer::Errors::NotImplemented
      end
    
      def get_subnet(id)
        raise ServiceLayer::Errors::NotImplemented
      end
    
      def create_subnet(params = {})
        raise ServiceLayer::Errors::NotImplemented
      end

      def update_subnet(id, params={})
        raise ServiceLayer::Errors::NotImplemented
      end
    
      def delete_subnet(id)
        raise ServiceLayer::Errors::NotImplemented
      end
    end
  end
end