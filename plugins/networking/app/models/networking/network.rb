module Networking
  class Network < Core::ServiceLayer::Model
    validates :name, presence: { message: 'Please provide a name' }

    def external
      read('router:external')
    end

    def provider_network_type
      read('provider:network_type')
    end

    def provider_physical_network
      read('provider:physical_network')
    end

    def provider_segmentation_id
      read('provider:segmentation_id')
    end

    def subnet_objects
      @driver.map_to(::Networking::Subnet).subnets(id)
    end

    def port_objects
      @driver.map_to(::Networking::Port).ports(id)
    end
  end
end
