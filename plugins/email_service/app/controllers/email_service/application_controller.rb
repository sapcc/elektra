# frozen_string_literal: true

module EmailService
  class ApplicationController < DashboardController
    authorization_context 'email_service'
    authorization_required

    def index
      enforce_permissions('email_service:application_list')
    end
  end
end
