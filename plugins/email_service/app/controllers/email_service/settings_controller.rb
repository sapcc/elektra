module EmailService
  class SettingsController < ::EmailService::ApplicationController

    before_action :check_ec2_creds_cronus_status
    before_action :check_verified_identity

    authorization_context 'email_service'
    authorization_required

    def index
      @nebula_details = nebula_details
      @nebula_status = nebula_status
      @nebula_endpoint = nebula_endpoint_url

      @cronus_active = false
      unless !ec2_creds && ec2_creds.nil?
        @access = ec2_creds.access
        @secret = ec2_creds.secret
        if @access && @secret
          @cronus_active = true
        end
      else
        error = "#{I18n.t('email_service.errors.cronus_account_activation')} : #{e.message}"
        Rails.logger.error error
        flash[:error] = error
        check_ec2_creds_cronus_status
      end
    rescue Elektron::Errors::ApiResponse => e
      error = "#{I18n.t('email_service.errors.cronus_account_details_list')} : #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    rescue Exception => e
      error = "#{I18n.t('email_service.errors.cronus_account_details_list')} : #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    end

  end
end
