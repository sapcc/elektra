module OpenstackServiceProvider
  module Driver
    # Compute calls
    class Compute < OpenstackServiceProvider::Driver::Base
    
      ########################### SERVERS ##############################  
      def servers(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def create_server(params={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def get_server(server_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def delete_server(server_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def reboot_server(server_id, type)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def rebuild_server(server_id, image_ref, name, admin_pass=nil, metadata=nil, personality=nil)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def resize_server(server_id, flavor_ref)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def confirm_resize_server(server_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def revert_resize_server(server_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def create_image(server_id, name, metadata={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def start_server(server_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def stop_server(server_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def attach_volume(volume_id, server_id, device)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def detach_volume(server_id, attachment_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def suspend_server(server_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
            
      def pause_server(server_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def unpause_server(server_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def reset_server_state(state)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def rescue_server(server_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def resume_server(server_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
    
      ########################### FLAVORS #############################
      def flavors(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def get_flavor(flavor_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def delete_flavor(flavor_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      ########################### IMAGES #############################
      
      def images(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def get_image(image_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def delete_image(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      #################### AVAILABILITY_ZONES ########################
      
      def availability_zones(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      
      ##################### SECURITY_GROUPS #########################
      def create_security_group(params={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def security_groups(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def server_security_groups(server_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def get_security_group(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def delete_security_group(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      
      ########################### VOLUMES #############################
      def create_volume(params={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def volumes(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def get_volume(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def delete_volume(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
    end
  end
end