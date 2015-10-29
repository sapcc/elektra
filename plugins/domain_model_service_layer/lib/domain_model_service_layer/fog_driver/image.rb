module DomainModelServiceLayer
  module FogDriver
    class Image < DomainModelServiceLayer::Driver::Image
      include FogDriver::ClientHelper
      
      def initialize(params)
        super(params)
        @fog = Fog::Image::OpenStack.new(auth_params)
      end  

      ########################### IMAGES #############################
      def images(filter={})
        handle_response{
          @fog.list_images(filter).body['images']
        }
      end
      
      def get_image(id)
        handle_response{
          @fog.get_image_by_id(id).body['image']
        }
      end
    end
  end
end