module EmailService
  class TemplatedEmailsController < ::EmailService::ApplicationController
    before_action :restrict_access
    before_action :fetch_aws_data, only: %i[new create edit]
    before_action :templated_email, only: %i[new edit]

    authorization_context 'email_service'
    authorization_required

    def new;end
    
    def edit;end

    def create

      @templated_email = templated_email_form(templated_email_params)
      templated_email_values = @templated_email.process(EmailService::TemplatedEmail)
      if @templated_email.valid?
        begin
          status = send_templated_email(templated_email_values) 
          if status == "success"
            flash[:success] = "eMail sent successfully"
            redirect_to plugin('email_service').emails_path and return
          else 
            flash.now[:error] = status
            render "edit", locals: {data: {modal: true} } and return
          end
        rescue Elektron::Errors::ApiResponse => e
          flash.now[:error] = "Status Code: #{e.code}; elektron error: #{e.message}"
        rescue Exception => e
          flash.now[:error] = "Status Code: 500; other error: #{e.message}"
        end
      else
        render "edit", locals: {data: {modal: true} } and return
      end
      redirect_to plugin('email_service').emails_path

    end

    private

    def fetch_aws_data
      creds = get_ec2_creds
      if creds.error.empty?
        @all_emails = list_verified_identities("EmailAddress")
        @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
        @verified_emails_collection = get_verified_identities_collection(@verified_emails, "EmailAddress")
        @templates = get_all_templates
        @templates_collection = get_templates_collection(@templates) if @templates && !@templates.empty?
        @configsets = list_configset_names
      else
        flash[:error] = creds.error
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def templated_email_form(attributes={})
      EmailService::Forms::TemplatedEmail.new(attributes)
    end

    def templated_email
      @templated_email = templated_email_form(templated_email_params)
    end

    def templated_email_params
      if params.include?(:templated_email)
        return params.require(:templated_email).permit(:source, :to_addr, :cc_addr, :bcc_addr, :reply_to_addr, :template_name, :template_data, :configset_name)
      else 
        return {}
      end
    end

  end
end
