# frozen_string_literal: true

module Keppel
  class ApplicationController < DashboardController
    def show
      enforce_permissions('::keppel:account:show')
      @edit_role = 'resource_admin'
      @js_data   = {
        # data required to access the Keppel API
        token:      current_user.token,
        keppel_api: current_user.service_url('keppel'),
        project_id: @scoped_project_id,

        # permission flags for the UI rendering
        can_edit:   current_user.is_allowed?('keppel:account:edit'),
        is_admin:   current_user.is_allowed?('keppel:account:admin'),

        # used to display instructions for how to use the Docker CLI with Keppel
        docker_cli_username: "#{current_user.name}@#{current_user.user_domain_name}/#{@scoped_project_name}@#{@scoped_domain_name}",
      }
    end
  end
end
