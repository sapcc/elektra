# frozen_string_literal: true

module EmailService
  # EmailService ApplicationController
  class ApplicationController < ::DashboardController
    include ::EmailService::ApplicationHelper

    authorization_context "email_service"
    authorization_required

    def check_ec2_creds_cronus_status
      return unless (!ec2_creds && ec2_creds.nil?) || !nebula_active?
      render "/email_service/shared/setup.html"
    end

    def check_verified_identity
      return unless (email_addresses.empty? && domains.empty?)
      render "/email_service/shared/setup.html"
    end

    protected

    helper_method :release_state

    def release_state
      "tech_preview"
    end
  end
end
