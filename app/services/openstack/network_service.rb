module Openstack
  class NetworkService < OpenstackServiceProvider::Service
    
    def get_driver(params)
      OpenstackServiceProvider::FogDriver::Network.new(params)
    end

    def networks(filter={})
      @driver.map_to(Network::Network).networks(filter)  
    end
    
    def accessible_networks(project_id)
      result = []
      @driver.networks.each do |n| 
        if n["shared"]==true or n["tenant_id"]==project_id
          result << Network::Network.new(@driver,n)
        end
      end
      result
    end
    
    def network(id)
      @driver.map_to(Network::Network).get_network(id)
    end
    
    def forms_network(id=nil)
      Forms::Network.new(self,id)
    end
    
    def create_network(params = {})
      @driver.map_to(Network::Network).create_network(params)
    end
    
    def find_network(id)
      @driver.map_to(Network::Network).get_network(id)
    end
    
    def subnets(network_id)
      @driver.map_to(Network::Network).subnets(network_id)
    end
    
    def ports(network_id)
      @driver.map_to(Network::Network).ports(network_id)
    end
  end
end