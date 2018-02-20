# frozen_string_literal: true

module Kubernetes
  class ApplicationController < DashboardController
    # authorization_context 'kubernetes'
    # authorization_required

    def release_state
      'beta'
    end

    def index
      # # enforce_permissions('kubernetes:application_list')
      # @kubernikus_endpoint = "#{current_user.service_url('kubernikus')}"
      # # Settings from Elektra extension
      # @beta_contact = {name: Settings.beta_contact_name, email: Settings.beta_contact_email}

      endpoint = current_user.has_service?("kubernikus-#{@scoped_project_name}") ? current_user.service_url("kubernikus-#{@scoped_project_name}") : current_user.service_url('kubernikus')

      render inline: "<div id='kubernetes_react_container' data-kubernikusBaseURL=#{endpoint} data-token=#{current_user.token}></div>",
             layout: true,
             content_type: 'text/html'
    end
  end
end
