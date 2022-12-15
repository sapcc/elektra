# frozen_string_literal: true

module ServiceLayer
  module ComputeServices
    # This module implements Openstack Compute API
    module SecurityGroup
      def security_group_map
        @security_group_map ||= class_map_proc(Compute::ServerSecurityGroup)
      end

      def security_groups_details(server_id)
        elektron_compute.get("servers/#{server_id}/os-security-groups").map_to(
          "body.security_groups",
          &security_group_map
        )
      end

      def remove_security_group(server_id, sg_id)
        elektron_compute.post("servers/#{server_id}/action") do
          { "removeSecurityGroup" => { "name" => sg_id } }
        end
      end

      def add_security_group(server_id, sg_id)
        elektron_compute.post("servers/#{server_id}/action") do
          { "addSecurityGroup" => { "name" => sg_id } }
        end
      end
    end
  end
end
