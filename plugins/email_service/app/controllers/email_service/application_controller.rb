# frozen_string_literal: true

module EmailService
  class ApplicationController < ::DashboardController

    include ::EmailService::ApplicationHelper

    authorization_context 'email_service'
    authorization_required

    def check_ec2_creds_cronus_status
      Rails.logger.debug "\n[email_service][application_controller][check_ec2_creds_cronus_status]\n"
      if ( !ec2_creds && ec2_creds.nil? ) || !nebula_active?
        render '/email_service/shared/setup.html'
      end
    end

    def check_verified_identity
      Rails.logger.debug "\n[email_service][application_controller][check_verified_identity]\n"
      if email_addresses.empty?
        Rails.logger.debug "\n[email_service][application_controller][check_verified_identity][email_addresses.empty?]\n"
        render '/email_service/shared/setup.html'
      end
    end

    protected

    helper_method :release_state

    def release_state
      'tech_preview'
    end

  end
end
