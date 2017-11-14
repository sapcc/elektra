# frozen_string_literal: true

module Kubernetes
  class ApplicationController < DashboardController
    authorization_context 'kubernetes'
    authorization_required

    def release_state
      'beta'
    end

    def index
      # enforce_permissions('kubernetes:application_get')
      @kubernikus_endpoint = "#{current_user.service_url('kubernikus')}"
      # Settings from Elektra extension
      @beta_contact = {name: Settings.beta_contact_name, email: Settings.beta_contact_email}
    end
  end
end
