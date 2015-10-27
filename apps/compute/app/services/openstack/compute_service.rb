module Openstack
  class ComputeService < OpenstackServiceProvider::Service
    
    def get_driver(params)
      driver = Compute::Driver.new(params)
      raise "Error" unless driver.is_a?(OpenstackServiceProvider::Driver::Compute)
      driver
    end
    
    ##################### CREDENTIALS #########################
    def server(id=nil)
      if id
        @driver.map_to(Compute::Server).get_server(id)
      else
        Compute::Server.new(@driver)
      end
    end
    
    def servers(filter={})
      @driver.map_to(Compute::Server).servers(filter)
    end
    
    def images
      @driver.map_to(Compute::Image).images
    end
    
    def image(id)
      @driver.map_to(Compute::Image).get_image(id)
    end
    
    def flavors
      @driver.map_to(Compute::Flavor).flavors
    end
    
    def flavor(id)
      @driver.map_to(Compute::Flavor).get_flavor(id)
    end
    
    def availability_zones
      @driver.map_to(Compute::AvailabilityZone).availability_zones
    end
    
    def security_groups
      @driver.map_to(Compute::SecurityGroup).security_groups
    end

  end
end