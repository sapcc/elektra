module Image
  # Compute calls
  module Driver
    class Interface < Core::ServiceLayer::Driver::Base
        
      ########################### IMAGES #############################
      def images(filter={})
        raise ServiceLayer::Errors::NotImplemented
      end
    
      def get_image(image_id)
        raise ServiceLayer::Errors::NotImplemented
      end
    end
  end
end