module BlockStorage
  class ApplicationController < DashboardController
    def widget
      @quota_data = []

      return unless current_user.is_allowed?('access_to_project')
      @quota_data = services.resource_management.quota_data(
        current_user.domain_id || current_user.project_domain_id,
        current_user.project_id, [
        { service_type: :volumev2, resource_name: :volumes },
        { service_type: :volumev2, resource_name: :snapshots },
        { service_type: :volumev2, resource_name: :capacity }
      ])
    end
  end
end
