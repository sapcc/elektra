module DomainModelServiceLayer
  module Driver
    # Neutron calls
    class Network < DomainModelServiceLayer::Driver::Base
      ###################### NETWORKS #######################
      def networks(filter={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
      
      def get_network(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
      
      def create_network(params = {})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def update_network(id, params={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
      
      def delete_network(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
      
      ###################### PORTS #######################
      def ports(network_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
      
      def get_port(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
      
      def create_port(params = {})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def update_port(id,params={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
      
      def delete_port(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
      
      ###################### SUBNETS #######################
      def subnets(network_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
      
      def get_subnet(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
      
      def create_subnet(params = {})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def update_subnet(id, params={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
      
      def delete_subnet(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    end
  end
end