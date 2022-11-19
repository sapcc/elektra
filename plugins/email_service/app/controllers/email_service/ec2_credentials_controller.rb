module EmailService
  class Ec2CredentialsController < ::EmailService::ApplicationController

    # before_action :check_ec2_creds_cronus_status
    # before_action :check_verified_identity

    authorization_context 'email_service'
    authorization_required

    def show;end

    def create

      @ec2_creds = create_credentials

      if @ec2_creds.access && @ec2_creds.secret
        flash[:info] = "ec2 credentials are created"
      else
        flash.now[:error] = "#{I18n.t('email_service.errors.ec2_credentials_create_error')} #{e.message}"
      end

      redirect_to ec2_credentials_path

    end

    def destroy

      @ec2_creds = ec2_creds

      if @ec2_creds && @ec2_creds.access && @ec2_creds.secret
        delete_credentials(@ec2_creds.access)
        flash.now[:info] = "ec2 credentials are deleted"
      else
        flash.now[:error] = "#{I18n.t('email_service.errors.ec2_credentials_delete_error')} #{e.message}"
      end

      redirect_to ec2_credentials_path

    end

  end
end
