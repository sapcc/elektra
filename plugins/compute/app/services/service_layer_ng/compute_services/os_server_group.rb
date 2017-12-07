# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module OsServerGroup
      def os_server_groups(filter = {})
        api.compute.list_server_groups(filter).map_to(
          'server_groups' => Compute::OsServerGroup
        )
      end

      def create_os_server_group(params = {})
        api.compute.create_server_group(params).data
      end

      def find_os_server_group!(id)
        api.compute.show_server_group_details(id).map_to(
          'server_group' => Compute::OsServerGroup
        )
      end

      def find_os_server_group(id)
        find_os_server_group!(id)
      rescue => _e
        nil
      end

      def delete_os_server_group(id)
        api.compute.delete_server_group(id)
      end
    end
  end
end
