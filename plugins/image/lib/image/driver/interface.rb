module Image
  # Compute calls
  module Driver
    class Interface < DomainModelServiceLayer::Driver::Base
        
      ########################### IMAGES #############################
      def images(filter={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def get_image(image_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    end
  end
end