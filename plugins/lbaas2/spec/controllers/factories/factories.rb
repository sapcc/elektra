module Lbaas2

  class FakeFactory

    def loadbalancer(params = {})
      {vip_subnet_id: "456", vip_network_id: "123", name: "test lb"} 
    end

  end
end