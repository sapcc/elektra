# frozen_string_literal: true

module ServiceLayerNg
  module NetworkingServices
    # Implements Openstack Router
    module Quota
      def project_quotas(project_id)
        api.networking.list_quotas_for_a_project(project_id)
           .map_to(Networking::Quota)
      end

      def quotas(filter = {})
        api.networking
           .list_quotas_for_projects_with_non_default_quota_values(filter)
           .map_to(Networking::Quota)
      end

      ################### Model Interface ###################
      def update_quota(id, attributes)
        api.networking.update_quota_for_a_project(
          id, quota: attributes
        ).data
      end

      def delete_quota(id)
        api.networking.reset_quota_for_a_project(id)
      end
    end
  end
end
