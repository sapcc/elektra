# frozen_string_literal: true

module SharedFilesystemStorage
  # Application controller for SharedFilesystemStorage
  class ApplicationController < ::DashboardController
    # set policy context
    authorization_context 'shared_filesystem_storage'
    # enforce permission checks. This will automatically
    # investigate the rule name.
    authorization_required

    def show
      @quota_data = []
      if current_user.is_allowed?("access_to_project")
        @quota_data = services.resource_management.quota_data(
          current_user.domain_id || current_user.project_domain_id,
          current_user.project_id,
          [
            { service_type: :sharev2, resource_name: :gigabytes },
            { service_type: :sharev2, resource_name: :shares },
            { service_type: :sharev2, resource_name: :snapshots },
            { service_type: :sharev2, resource_name: :share_networks },
            { service_type: :sharev2, resource_name: :share_groups }
          ]
        )
      end
    end
  end
end
