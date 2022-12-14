# frozen_string_literal: true

module ServiceLayer
  module ComputeServices
    # This module implements Openstack Compute Interface API
    module OsInterface
      def os_interface_map
        @os_interface_map ||= class_map_proc(Compute::OsInterface)
      end

      def server_os_interfaces(server_id)
        elektron_compute.get("servers/#{server_id}/os-interface").map_to(
          "body.interfaceAttachments",
          &os_interface_map
        )
      end

      def new_os_interface(server_id, params = {})
        params = params.to_unsafe_hash if params.respond_to?(:to_unsafe_hash)
        os_interface_map.call({ server_id: server_id }.merge(params))
      end

      ######################## MODEL INTERFACE ###################
      # this is a special case and called from OsInterface model
      # perform_create()
      def create_os_interface(server_id, attributes)
        elektron_compute
          .post("servers/#{server_id}/os-interface") do
            { "interfaceAttachment" => attributes }
          end
          .body[
          "interfaceAttachment"
        ]
      end

      def delete_os_interface(server_id, port_id)
        elektron_compute.delete("servers/#{server_id}/os-interface/#{port_id}")
      end
    end
  end
end
