module OpenstackServiceProvider
  module Driver
    # Compute calls
    class Image < OpenstackServiceProvider::Driver::Base
          
      ########################### IMAGES #############################
      def images(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def get_image(image_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
    end
  end
end