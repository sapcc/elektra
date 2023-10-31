# frozen_string_literal: true

module EmailService
  class Ec2CredentialsController < ::EmailService::ApplicationController
    authorization_context 'email_service'
    authorization_required

    before_action :set_ec2_credential, only: %i[show edit destroy]

    def index; end
    def new; end
    def show; end

    def create
      @ec2_creds = create_credentials

      if @ec2_creds.access && @ec2_creds.secret
        flash[:info] = 'ec2 credentials are created'
      else
        error =
          "#{I18n.t('email_service.errors.ec2_credentials_create_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      end

      redirect_to ec2_credentials_path
    end

    def destroy
      begin
        delete_credentials(@ec2_credential.access)
        flash.now[:info] = 'ec2 credentials are deleted'
      rescue Elektron::Errors::ApiResponse, StandardError => e
        flash.now[:error] = "#{I18n.t('email_service.errors.ec2_credentials_delete_error')} #{e.message}"
      end

      redirect_to ec2_credentials_path
    end

    def set_ec2_credential
      access_id = params[:id]

      Rails.logger.debug(" access_id: #{access_id}")
      @ec2_credential = find_credentials(user_id, access_id, {})
    end
  end
end
