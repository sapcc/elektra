module Image
  module Driver
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper
      attr_reader :available

      def initialize(params)
        super(params)
        # pin to V2 for now, V1 has some different attributes
        @fog = ::Fog::Image::OpenStack::V2.new(auth_params)
        @available = true
      rescue ::Fog::OpenStack::Errors::ServiceUnavailable
        @fog = nil
        @available = false
      end

      def handle_api_errors?
        false
      end

      ########################### IMAGES #############################
      def images(filter = {})
        handle_response { @fog.list_images(filter).body['images'] }
      end

      def get_image(id)
        handle_response { @fog.get_image_by_id(id).body }
      rescue ::Fog::Image::OpenStack::NotFound
        nil
      end
      
      def add_member_to_image(image_id, tenant_id)
        handle_response { @fog.add_member_to_image(image_id, tenant_id).body}
      end

      ########################### MEMBERS #############################
      def members(id)
        handle_response { @fog.get_image_members(id).body['members'] }
      # not implemented in monsoon2 sm
      rescue Excon::Errors::NotImplemented
      end
    end
  end
end
