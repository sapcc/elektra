module EmailService
  class PlainEmailsController < ::EmailService::ApplicationController
    before_action :restrict_access
    before_action :check_user_creds_roles
    before_action :plain_email, only: %i[new edit]

    authorization_context 'email_service'
    authorization_required

    def new
      @source_types = ::EmailService::Email.source_types
    end
    
    def edit;end

    def create

      @source_types = ::EmailService::Email.source_types
      
      @plain_email = plain_email_form(plain_email_params)

      if @plain_email.source_type == "domain"
        @plain_email.source = @plain_email.source_domain_name_part == nil ? "test@#{@plain_email.source_domain}" : "#{@plain_email.source_domain_name_part}@#{@plain_email.source_domain}"
      elsif @plain_email.source_type == "email"
        @plain_email.source = @plain_email.source_email
      end

      plain_email_values = @plain_email.process(EmailService::PlainEmail)

      if @plain_email.valid?
        begin
          status = send_plain_email(plain_email_values) 
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

      def plain_email_form(attributes={})
        EmailService::Forms::PlainEmail.new(attributes)
      end

      def plain_email
        @plain_email = plain_email_form(plain_email_params)
      end

      def plain_email_params
        if params.include?(:plain_email)
          return params.require(:plain_email).permit(:source, :source_domain, :source_domain_name_part, :source_email, :source_type, :to_addr, :cc_addr, :bcc_addr, :reply_to_addr, :return_path, :subject, :html_body, :text_body)
        else 
          return {}
        end
      end

  end
end

