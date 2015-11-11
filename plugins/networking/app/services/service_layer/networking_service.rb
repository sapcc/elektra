module ServiceLayer
  class NetworkingService < DomainModelServiceLayer::Service
  
    def init(params)
      @driver = Networking::Driver::Fog.new(params)
      raise "Error" unless @driver.is_a?(Networking::Driver::Interface)
    end

    def networks(filter={})
      @driver.map_to(Networking::Network).networks(filter)  
    end
  
    def project_networks(project_id)
      result = []
      @driver.networks.each do |n| 
        if n["shared"]==true or n["tenant_id"]==project_id
          result << Networking::Network.new(@driver,n)
        end
      end
      result
    end
  
    def network(id=nil)
      if id
        @driver.map_to(Networking::Network).get_network(id)
      else
        Networking::Network.new(@driver)
      end
    end
  
    def subnet(id=nil)
      if id
        @driver.map_to(Networking::Subnet).get_subnet(id)
      else
        Networking::Subnet.new(@driver)
      end
    end
  
    def subnets(network_id)
      @driver.map_to(Networking::Subnet).subnets(network_id)
    end
  
    def ports(network_id)
      @driver.map_to(Networking::Port).ports(network_id)
    end
  end
end