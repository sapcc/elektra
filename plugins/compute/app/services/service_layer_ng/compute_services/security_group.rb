# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module SecurityGroup
      def security_groups_details(server_id)
        api.compute.list_security_groups_by_server(server_id)
           .map_to(Networking::SecurityGroup)
      end

      def remove_security_group(server_id, sg_id)
        api.compute
           .remove_security_group_from_a_server_removesecuritygroup_action(
             server_id, 'removeSecurityGroup' => { 'name' => sg_id }
           )
      end

      def add_security_group(server_id, sg_id)
        api.compute.add_security_group_to_a_server_addsecuritygroup_action(
          server_id, 'addSecurityGroup' => { 'name' => sg_id }
        )
      end
    end
  end
end
