# frozen_string_literal: true

module ServiceLayer
  module NetworkingServices
    # Implements Openstack RBAC
    module Rbac
      def rbac_map
        @rbac_map ||= class_map_proc(Networking::Rbac)
      end

      def rbacs(filter = {})
        elektron_networking.get("rbac-policies", filter).map_to(
          "body.rbac_policies",
          &rbac_map
        )
      end

      def find_rbac!(id)
        return nil unless id
        elektron_networking.get("rbac-policies/#{id}").map_to(
          "body.rbac_policy",
          &rbac_map
        )
      end

      def find_rbac(id)
        find_rbac!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_rbac(attributes = {})
        rbac_map.call(attributes)
      end

      # Model Interface
      def create_rbac(attributes)
        elektron_networking
          .post("rbac-policies") { { rbac_policy: attributes } }
          .body[
          "rbac_policy"
        ]
      end

      def delete_rbac(id)
        elektron_networking.delete("rbac-policies/#{id}")
      end

      def update_rbac(id, attributes)
        elektron_networking
          .put("rbac-policies/#{id}") { { rbac_policy: attributes } }
          .body[
          "rbac_policy"
        ]
      end
    end
  end
end
