# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module OsInterface
      def new_os_interface(server_id, params = {})
        os_interface = map_to(Compute::OsInterface, params)
        # the server_id is needed to bind the interface on the related server
        # take a look to innstances_controller create_interface()
        os_interface.server_id = server_id
        os_interface
      end

      # this is a special case and called from OsInterface model
      # perform_create()
      def create_os_interface(server_id, attributes)
        api.compute.create_interface(
          server_id, interfaceAttachment: attributes
        ).data
      end

      def delete_os_interface(server_id, port_id)
        api.compute.detach_interface(server_id, port_id)
      end

      def server_os_interfaces(server_id)
        api.compute.list_port_interfaces(server_id).map_to(Compute::OsInterface)
      end
    end
  end
end
