module Networking
  class Network < DomainModelServiceLayer::Model
    
    validates :name, presence: {message: 'Please provide a name'}

    def subnet_objects
      @driver.map_to(::Networking::Subnet).subnets(id)
    end
    
    def port_objects
      @driver.map_to(::Networking::Port).ports(id)
    end
  end
end