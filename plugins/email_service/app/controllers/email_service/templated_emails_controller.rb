module EmailService
  class TemplatedEmailsController < ::EmailService::ApplicationController

    before_action :check_ec2_creds_cronus_status
    before_action :check_verified_identity

    before_action :templated_email, only: %i[new edit]

    authorization_context 'email_service'
    authorization_required

    def new
      @source_types = ::EmailService::Email.source_types
    end

    def edit;end

    def create

      @source_types = ::EmailService::Email.source_types

      @templated_email = templated_email_form(templated_email_params)

      if @templated_email.source_type == "domain"
        @templated_email.source = @templated_email.source_domain_name_part == "" ? \
          "test@#{@templated_email.source_domain}" : \
          "#{@templated_email.source_domain_name_part}@#{@templated_email.source_domain}"
      elsif @templated_email.source_type == "email"
        @templated_email.source = @templated_email.source_email
      end

      if @templated_email.return_path == ""
        @templated_email.return_path = @templated_email.source
      end

      templated_email_values = @templated_email.process(EmailService::TemplatedEmail)


      Rails.logger.debug "\n===================================================\n"
      Rails.logger.debug "\n [TemplatedEmailsController][create] \n"
      Rails.logger.debug "\n @templated_email.inspect : #{@templated_email.inspect} \n"
      Rails.logger.debug "\n===================================================\n"

      if @templated_email.valid?
        begin
          status = send_templated_email(templated_email_values)

          Rails.logger.debug "\n===================================================\n"
          Rails.logger.debug "\n [TemplatedEmailsController][create] \n"
          Rails.logger.debug "\n status : #{status} \n"
          Rails.logger.debug "\n===================================================\n"

          if status == "success"
            flash[:success] = "eMail sent successfully"
            redirect_to plugin('email_service').emails_path and return
          # else
          #   flash[:error] = status
          #   render "edit", locals: {data: {modal: true} } and return
          end
        rescue Elektron::Errors::ApiResponse => e
          flash[:error] = "Status Code: #{e.code}; elektron error: #{e.message}"
        rescue Exception => e
          flash[:error] = "Status Code: 500; other error: #{e.message}"
        end
      else
        render "edit", locals: {data: {modal: true} } and return
      end
      redirect_to plugin('email_service').emails_path

    end

    private

    def templated_email_form(attributes={})
      EmailService::Forms::TemplatedEmail.new(attributes)
    end

    def templated_email
      @templated_email = templated_email_form(templated_email_params)
    end

    def templated_email_params
      if params.include?(:templated_email)
        return params.require(:templated_email).permit(:source, :source_domain, :source_domain_name_part, :source_email, :source_type, :to_addr, :cc_addr, :bcc_addr, :reply_to_addr, :return_path, :template_name, :template_data, :configset_name)
      else
        return {}
      end
    end

  end
end
