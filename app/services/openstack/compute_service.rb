module Openstack
  class ComputeService < OpenstackServiceProvider::FogProvider
    
    def driver(auth_params)
      #TODO: remove this shit
      auth_params[:connection_options]= { ssl_verify_peer: false }
      
      Fog::Compute::OpenStack.new(auth_params)
    end
    
    ##################### CREDENTIALS #########################
    def forms_instance(id=nil)
      Forms::Instance.new(self,id)
    end
    
    def create_instance(options = {})
      @driver.servers.create(options)
    end
    
    def find_instance(id)
      @driver.servers.get(id)
    end
  end
end