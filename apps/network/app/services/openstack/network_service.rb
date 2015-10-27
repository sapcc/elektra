module Openstack
  class NetworkService < OpenstackServiceProvider::Service
  
    def get_driver(params)
      OpenstackServiceProvider::FogDriver::Network.new(params)
    end

    def networks(filter={})
      @driver.map_to(Network::Network).networks(filter)  
    end
  
    def project_networks(project_id)
      result = []
      @driver.networks.each do |n| 
        if n["shared"]==true or n["tenant_id"]==project_id
          result << Network::Network.new(@driver,n)
        end
      end
      result
    end
  
    def network(id=nil)
      if id
        @driver.map_to(Network::Network).get_network(id)
      else
        Network::Network.new(@driver)
      end
    end
  
    def subnet(id=nil)
      if id
        @driver.map_to(Network::Subnet).get_subnet(id)
      else
        Network::Subnet.new(@driver)
      end
    end
  
    def subnets(network_id)
      @driver.map_to(Network::Subnet).subnets(network_id)
    end
  
    def ports(network_id)
      @driver.map_to(Network::Port).ports(network_id)
    end
  end
end