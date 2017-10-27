# frozen_string_literal: true

module Kubernetes
  class ApplicationController < DashboardController
    authorization_context 'kubernetes'
    authorization_required

    def index
      enforce_permissions('kubernetes:application_get')
      @kubernikus_endpoint = "#{current_user.service_url('kubernikus')}"
    end
  end
end
