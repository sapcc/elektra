# frozen_string_literal: true

module Kubernetes
  class ApplicationController < DashboardController
    # authorization_context 'kubernetes'
    # authorization_required

    def release_state
      'public_release'
    end

    def index
      # enforce_permissions('kubernetes:application_list')
      @kubernikus_endpoint = current_user.has_service?("kubernikus-#{@scoped_project_name}") ? current_user.service_url("kubernikus-#{@scoped_project_name}") : current_user.service_url('kubernikus')
    end
  end
end
