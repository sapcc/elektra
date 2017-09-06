# frozen_string_literal: true

module Kubernetes
  class ApplicationController < DashboardController
    authorization_context 'audit'
    authorization_required

    def index
      enforce_permissions('kubernetes:application_get')
      @kubernikus_endpoint = "#{current_user.service_url('kubernikus')}/api/v1"
    end
  end
end
