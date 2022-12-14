# frozen_string_literal: true

module ServiceLayer
  module ComputeServices
    # This module implements Openstack Domain API
    module OsServerGroup
      def os_server_group_map
        @os_server_group_map ||= class_map_proc(Compute::OsServerGroup)
      end

      def os_server_groups(filter = {})
        elektron_compute.get("os-server-groups", filter).map_to(
          "body.server_groups",
          &os_server_group_map
        )
      end

      def find_os_server_group!(id)
        elektron_compute.get("os-server-groups/#{id}").map_to(
          "body.server_group",
          &os_server_group_map
        )
      end

      def find_os_server_group(id)
        find_os_server_group!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      ################### MODEL INTERFACE ##################
      def create_os_server_group(params = {})
        elektron_compute
          .post("os-server-groups") { { "server_group" => params } }
          .body[
          "server_group"
        ]
      end

      def delete_os_server_group(id)
        elektron_compute.delete("os-server-groups/#{id}")
      end
    end
  end
end
