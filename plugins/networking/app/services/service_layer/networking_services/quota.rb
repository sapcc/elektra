# frozen_string_literal: true

module ServiceLayer
  module NetworkingServices
    # Implements Openstack Router
    module Quota
      def quota_map
        @quota_map ||= class_map_proc(Networking::Quota)
      end

      def project_quotas(project_id)
        elektron_networking.get("quotas/#{project_id}").map_to(
          "body.quota",
          &quota_map
        )
      end

      def quotas(filter = {})
        elektron_networking.get("quotas", filter).map_to(
          "body.quotas",
          &quota_map
        )
      end

      ################### Model Interface ###################
      def update_quota(project_id, attributes)
        elektron_networking
          .put("quotas/#{project_id}") { { quota: attributes } }
          .body[
          "quota"
        ]
      end

      def delete_quota(project_id)
        elektron_networking.delete("quotas/#{project_id}")
      end
    end
  end
end
