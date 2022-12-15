module Networking
  # Implements Network actions
  class WidgetsController < DashboardController
    # set policy context
    authorization_context "networking"
    # enforce permission checks. This will automatically
    # investigate the rule name.
    authorization_required only: %i[ports bgp_vpns]

    def bgp_vpns
    end

    def security_groups
      @quota_data = []
      return unless current_user.is_allowed?("access_to_project")

      @quota_data =
        services.resource_management.quota_data(
          current_user.domain_id || current_user.project_domain_id,
          current_user.project_id,
          [
            { service_type: :network, resource_name: :security_groups },
            { service_type: :network, resource_name: :security_group_rules },
          ],
        )
    end

    def ports
    end
  end
end
