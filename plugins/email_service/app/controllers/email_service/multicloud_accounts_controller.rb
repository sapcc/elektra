module EmailService
  class MulticloudAccountsController < ::EmailService::ApplicationController
    before_action :restrict_access
    before_action :set_multicloud_account, only: %i[new destroy]

    authorization_context 'email_service'
    authorization_required

    def index
      @nebula_status = nebula_status
    end

    def new
    end

    def edit
    end

    def create
      @multicloud_account = multicloud_account_form(multicloud_account_params)
      multicloud_account_values = @multicloud_account.process(EmailService::MulticloudAccount)
      if @multicloud_account.valid?
        status = nebula_activate(multicloud_account_values)
        status == "success"
        if status == "success"
          flash[:success] = "Cronus is enabled for your project"
          redirect_to plugin('email_service').emails_path and return
        else
          flash.now[:error] = status
          render "new", locals: {data: {modal: true} } and return
        end
      else
        render "new", locals: {data: {modal: true} } and return
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
      redirect_to plugin('email_service').emails_path
    end


    def destroy
      @multicloud_account.provider = "aws"
      status = nebula_deactivate(@multicloud_account)
      # @nebula_status : returns error 	failed to get a Nebula account status: account is marked as terminated 
      if status == "success"
        flash[:success] = "Cronus is disabled for your project"
      else
        flash[:error] = status
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

