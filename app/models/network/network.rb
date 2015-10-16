module Network
  class Network < OpenstackServiceProvider::BaseObject

    def subnet_objects
      @driver.map_to(::Network::Subnet).subnets(id)
    end
    
    def port_objects
      @driver.map_to(::Network::Port).ports(id)
    end
  end
end