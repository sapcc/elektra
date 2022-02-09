module EmailService
  class PlainEmailsController < ::EmailService::ApplicationController
    before_action :restrict_access
    before_action :plain_email, only: %i[new edit]

    authorization_context 'email_service'
    authorization_required

    def new;end
    
    def edit;end

    def create
      @plain_email = plain_email_form(plain_email_params)
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
          return params.require(:plain_email).permit(:source, :to_addr, :cc_addr, :bcc_addr, :subject, :html_body, :text_body)
        else 
          return {}
        end
      end

  end
end

