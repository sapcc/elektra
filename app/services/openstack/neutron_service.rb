module Openstack
  class NeutronService < OpenstackServiceProvider::FogProvider
<<<<<<< HEAD

=======
    
>>>>>>> d776d6815de1459bce50abc190ccf882905d0b39
    def driver(auth_params)
      auth_params[:connection_options]= { ssl_verify_peer: false }
      Fog::Network::OpenStack.new(auth_params)
    end
<<<<<<< HEAD

=======
    
>>>>>>> d776d6815de1459bce50abc190ccf882905d0b39
    ##################### CREDENTIALS #########################
    def forms_network(id=nil)
      #Forms::Network.new(self,id)
    end
<<<<<<< HEAD

    def create_network(options = {})
      #@driver.networks.create(options)
    end

    def find_network(id)
      #@driver.networks.get(id)
=======
    
    def create_network(options = {})
      @driver.networks.create(options)
    end
    
    def find_network(id)
      @driver.networks.get(id)
>>>>>>> d776d6815de1459bce50abc190ccf882905d0b39
    end
  end
end