# frozen_string_literal: true

module ServiceLayer
  module NetworkingServices
    # Implements Openstack SecurityGroup
    module SecurityGroup
      def security_group_map
        @security_group_map ||= class_map_proc(Networking::SecurityGroup)
      end

      def security_groups(filter = {})
        elektron_networking.get("security-groups", filter).map_to(
          "body.security_groups",
          &security_group_map
        )
      end

      def new_security_group(attributes = {})
        security_group_map.call(attributes)
      end

      def find_security_group!(id)
        return nil unless id
        elektron_networking.get("security-groups/#{id}").map_to(
          "body.security_group",
          &security_group_map
        )
      end

      def find_security_group(id)
        find_security_group!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      ########### Model Interface ###################
      def create_security_group(attributes)
        elektron_networking
          .post("security-groups") { { security_group: attributes } }
          .body[
          "security_group"
        ]
      end

      def update_security_group(id, attributes)
        elektron_networking
          .put("security-groups/#{id}") { { security_group: attributes } }
          .body[
          "security_group"
        ]
      end

      def delete_security_group(id)
        elektron_networking.delete("security-groups/#{id}")
      end
    end
  end
end
