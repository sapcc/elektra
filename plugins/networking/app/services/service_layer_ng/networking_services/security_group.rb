# frozen_string_literal: true

module ServiceLayerNg
  module NetworkingServices
    # Implements Openstack SecurityGroup
    module SecurityGroup
      def security_groups(filter = {})
        api.networking.list_security_groups(filter)
           .map_to(Networking::SecurityGroup)
      end

      def new_security_group(attributes = {})
        map_to(Networking::SecurityGroup, attributes)
      end

      def find_security_group!(id)
        return nil unless id
        api.networking.show_security_group(id).map_to(Networking::SecurityGroup)
      end

      def find_security_group(id)
        find_security_group!(id)
      rescue
        nil
      end

      ########### Model Interface ###################
      def create_security_group(attributes)
        api.networking.create_security_group(security_group: attributes).data
      end

      def update_security_group(id, attributes)
        api.networking
           .update_security_group(id, security_group: attributes).data
      end

      def delete_security_group(id)
        api.networking.delete_security_group(id)
      end
    end
  end
end
