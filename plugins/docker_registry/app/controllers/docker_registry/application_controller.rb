# frozen_string_literal: true

module DockerRegistry
  class ApplicationController < DashboardController
    def show
      enforce_permissions('keppel:account:show')
      @edit_role = 'resource_admin'
      @js_data   = {
        token:      current_user.token,
        keppel_api: current_user.service_url('keppel'),
        project_id: @scoped_project_id,
        can_edit:   current_user.is_allowed?('keppel:account:edit'),
        is_admin:   current_user.is_allowed?('keppel:account:admin'),
      }
    end
  end
end
