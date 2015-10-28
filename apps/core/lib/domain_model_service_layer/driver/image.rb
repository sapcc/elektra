module DomainModelServiceLayer
  module Driver
    # Compute calls
    class Image < DomainModelServiceLayer::Driver::Base
          
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