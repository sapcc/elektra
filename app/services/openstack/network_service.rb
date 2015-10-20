module Openstack
  class NetworkService < OpenstackServiceProvider::FogProvider
    
    def driver(auth_params)
      auth_params[:connection_options]= { ssl_verify_peer: false, debug:true }
      Fog::Network::OpenStack.new(auth_params)
    end

    ##################### CREDENTIALS #########################
    def forms_network(id=nil)
      Forms::Network.new(self,id)
    end
    
    def create_network(options = {})
      @driver.networks.create(options)
    end
    
    def find_network(id)
      @driver.networks.get(id)
    end
    
    def subnets(network_id)
      @driver.subnets.all( network_id: network_id)
    end
    
    def ports(network_id)
      @driver.ports.all( network_id: network_id)
    end
  end
end