module Openstack
  class NeutronService < OpenstackServiceProvider::FogProvider
    
    def driver(auth_params)
      Fog::Network::OpenStack.new(auth_params)
    end
    
    ##################### CREDENTIALS #########################
    def forms_network(id=nil)
      #Forms::Network.new(self,id)
    end
    
    def create_network(options = {})
      @driver.networks.create(options)
    end
    
    def find_network(id)
      @driver.networks.get(id)
    end
  end
end