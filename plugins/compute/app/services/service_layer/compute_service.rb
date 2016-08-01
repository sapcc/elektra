module ServiceLayer
  class ComputeService < Core::ServiceLayer::Service
    @@images_mutex = Mutex.new
    @@flavors_mutex = Mutex.new
    @@images = {}
    @@flavors = {}
      
    def driver
      @driver ||= Compute::Driver::Fog.new({
        auth_url:   self.auth_url,
        region:     self.region,
        token:      self.token,
        domain_id:  self.domain_id,
        project_id: self.project_id  
      })
    end
    
    def available?(action_name_sym=nil)
      not current_user.service_url('compute',region: region).nil?  
    end
    
    def find_server(id)
      return nil if id.blank?
      driver.map_to(Compute::Server).get_server(id)
    end
    
    def vnc_console(server_id,console_type='novnc')
      driver.map_to(Compute::VncConsole).vnc_console(server_id,console_type)      
    end
    
    def new_server(params={})
      Compute::Server.new(driver,params)
    end
    
    def servers(filter={})
      driver.map_to(Compute::Server).servers(filter)
    end
    
    def images
      driver.map_to(Compute::Image).images
    end
    
    def image(id)
      return nil if id.blank?

      image = @@images[id]
      unless image
        @@images_mutex.synchronize do
          image = @@images[id] = driver.get_image(id)
        end
      end
      Compute::Image.new(driver,image)        
    end
    
    def flavors
      driver.map_to(Compute::Flavor).flavors
    end
    
    def flavor(id)
      return nil if id.blank?

      flavor = @@flavors[id]
      unless flavor
        @@flavors_mutex.synchronize do
          flavor = @@flavors[id] = driver.get_flavor(id)
        end
      end
      Compute::Flavor.new(driver,flavor)
    end
    
    def availability_zones
      driver.map_to(Compute::AvailabilityZone).availability_zones
    end

    def attach_volume(volume_id, server_id, device)
      driver.attach_volume(volume_id, server_id, device)
    end

    def detach_volume(volume_id, server_id)
      driver.detach_volume(server_id, volume_id)
    end

    ##################### KEYPAIRS #########################
    def new_keypair(attributes={})
      Compute::Keypair.new(driver, attributes)
    end

    def find_keypair(name=nil)
      return nil if name.blank?
      driver.map_to(Compute::Keypair).get_keypair(name)
    end

    def delete_keypair(name=nil)
      return nil if name.blank?
      driver.map_to(Compute::Keypair).delete_keypair(name)
    end

    def keypairs(options={})
      # keypair structure different to others, so manual effort needed
      unless @user_keypairs
        @user_keypairs = []
        keypairs = driver.map_to(Compute::Keypair).keypairs(user_id: @current_user.id)
        keypairs.each do |k|
          kp = Compute::Keypair.new(@driver)
          kp.attributes = k.keypair if k.keypair
          @user_keypairs << kp if kp
        end
      end
      return @user_keypairs
    end



  end
end