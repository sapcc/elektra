module EmailService
  class Ec2CredentialsController < ::EmailService::ApplicationController
    authorization_context "email_service"
    authorization_required

    def create
      @ec2_creds = create_credentials

      if @ec2_creds.access && @ec2_creds.secret
        flash[:info] = "ec2 credentials are created"
      else
        error =
          "#{I18n.t("email_service.errors.ec2_credentials_create_error")} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      end

      redirect_to ec2_credentials_path
    end

    def destroy
      @ec2_creds = ec2_creds

      if @ec2_creds && @ec2_creds.access && @ec2_creds.secret
        delete_credentials(@ec2_creds.access)
        flash.now[:info] = "ec2 credentials are deleted"
      else
        error =
          "#{I18n.t("email_service.errors.ec2_credentials_delete_error")} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      end

      redirect_to ec2_credentials_path
    end
  end
end
