module EmailService
  class PlainEmailsController < ::EmailService::ApplicationController
    before_action :check_ec2_creds_cronus_status
    before_action :check_verified_identity

    before_action :plain_email, only: %i[new edit]

    authorization_context "email_service"
    authorization_required

    PLAIN_EMAIL_SENT = "#{I18n.t("email_service.messages.plain_email_sent")}"

    def new
      @source_types = ::EmailService::Email.source_types
    end

    def edit
    end

    def create
      @source_types = ::EmailService::Email.source_types

      @plain_email = plain_email_form(plain_email_params)

      if @plain_email.source_type == "domain"
        @plain_email.source =
          (
            if @plain_email.source_domain_name_part == ""
              "test@#{@plain_email.source_domain}"
            else
              "#{@plain_email.source_domain_name_part}@#{@plain_email.source_domain}"
            end
          )
      elsif @plain_email.source_type == "email"
        @plain_email.source = @plain_email.source_email
      end

      Rails.logger.debug "\n [email_service][plain_emails_controller][create] : \n @plain_email.source : #{@plain_email.source} \n"

      if @plain_email.return_path == ""
        @plain_email.return_path = @plain_email.source
      end

      plain_email_values = @plain_email.process(EmailService::PlainEmail)

      if @plain_email.valid?
        begin
          status = send_plain_email(plain_email_values)
          if status.include?("success")
            Rails.logger.debug "\n [email_service][plain_emails_controller][send_plain_email][@plain_email.valid?]"
            flash[:success] = PLAIN_EMAIL_SENT
            redirect_to plugin("email_service").emails_path and return
          else
            Rails.logger.debug "\n [email_service][plain_emails_controller][send_plain_email][@plain_email.valid?] : STATUS : #{status} \n"
            Rails.logger.error status
            flash[:error] = status
            render "edit", locals: { data: { modal: true } } and return
          end
        rescue Elektron::Errors::ApiResponse => e
          error =
            "#{I18n.t("email_service.errors.plain_email_send_error")} #{e.message}"
          Rails.logger.error error
          flash[:error] = error
        rescue Exception => e
          error =
            "#{I18n.t("email_service.errors.plain_email_send_error")} #{e.message}"
          Rails.logger.error error
          flash[:error] = error
        end
      else
        render "edit", locals: { data: { modal: true } } and return
      end
      redirect_to plugin("email_service").emails_path
    end

    private

    def plain_email_form(attributes = {})
      EmailService::Forms::PlainEmail.new(attributes)
    end

    def plain_email
      @plain_email = plain_email_form(plain_email_params)
    end

    def plain_email_params
      if params.include?(:plain_email)
        return(
          params.require(:plain_email).permit(
            :source,
            :source_domain,
            :source_domain_name_part,
            :source_email,
            :source_type,
            :to_addr,
            :cc_addr,
            :bcc_addr,
            :reply_to_addr,
            :return_path,
            :subject,
            :html_body,
            :text_body,
            :configuration_set_name,
          )
        )
      else
        return {}
      end
    end
  end
end
