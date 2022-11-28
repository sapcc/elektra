module EmailService
  class MulticloudAccountsController < ::EmailService::ApplicationController

    before_action :check_ec2_creds_cronus_status
    before_action :check_verified_identity

    before_action :set_multicloud_account, only: %i[new destroy]

    authorization_context 'email_service'
    authorization_required

    MULTICLOUD_ACCOUNT_CREATED = "#{I18n.t('email_service.messages.multicloud_accoount_created')}"
    MULTICLOUD_ACCOUNT_DELETED = "#{I18n.t('email_service.messages.multicloud_accoount_removed')}"

    def index
      @nebula_status = nebula_status
    end

    def new
    end

    def create
      @multicloud_account = multicloud_account_form(multicloud_account_params)
      multicloud_account_values = @multicloud_account.process(EmailService::MulticloudAccount)
      if @multicloud_account.valid?
        status = nebula_activate(multicloud_account_values)
        if status == "success"
          flash[:success] = MULTICLOUD_ACCOUNT_CREATED
          redirect_to plugin('email_service').emails_path and return
        else
          flash.now[:error] = status
          render "new", locals: {data: {modal: true} } and return
        end
      else
        render "new", locals: {data: {modal: true} } and return
      end
      rescue Elektron::Errors::ApiResponse => e
        error = "#{I18n.t('email_service.errors.multicloud_account_create')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
      redirect_to plugin('email_service').emails_path
    end


    def destroy
      @multicloud_account.provider = "aws"
      status = nebula_deactivate(@multicloud_account)
      # @nebula_status : returns error 	failed to get a Nebula account status: account is marked as terminated
      if status == "success"
        flash[:success] = MULTICLOUD_ACCOUNT_DELETED
      else
        error = "#{I18n.t('email_service.errors.multicloud_account_delete')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      end
      redirect_to plugin('email_service').settings_url
    end

    private

      def multicloud_account_form(attributes={})
        EmailService::Forms::MulticloudAccount.new(attributes)
      end

      def set_multicloud_account
        @multicloud_account = multicloud_account_form(multicloud_account_params)
      end

      def multicloud_account_params
        if params.include?(:multicloud_account)
          return params.require(:multicloud_account).permit(:account_env, :identity, :mail_type, :provider, :security_officer, :endpoint_url)
        else
          return {}
        end
      end

  end
end
