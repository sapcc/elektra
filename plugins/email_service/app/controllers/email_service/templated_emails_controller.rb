module EmailService
  class TemplatedEmailsController < ::EmailService::ApplicationController
    before_action :check_ec2_creds_cronus_status
    before_action :check_verified_identity

    before_action :templated_email, only: %i[new edit]

    authorization_context "email_service"
    authorization_required

    TEMPLATED_EMAIL_SENT =
      "#{I18n.t("email_service.messages.templated_email_sent")}"

    def new
      @source_types = ::EmailService::Email.source_types
    end

    def create
      @source_types = ::EmailService::Email.source_types

      @templated_email = templated_email_form(templated_email_params)

      if @templated_email.source_type == "domain"
        @templated_email.source =
          (
            if @templated_email.source_domain_name_part == ""
              "test@#{@templated_email.source_domain}"
            else
              "#{@templated_email.source_domain_name_part}@#{@templated_email.source_domain}"
            end
          )
      elsif @templated_email.source_type == "email"
        @templated_email.source = @templated_email.source_email
      end

      if @templated_email.return_path == ""
        @templated_email.return_path = @templated_email.source
      end

      if @templated_email.tags.empty?
        @templated_email.tags = [
          {
            name: "name1", # required
            value: "value1", # required
          },
        ]
      end

      templated_email_values =
        @templated_email.process(EmailService::TemplatedEmail)

      if @templated_email.valid?
        begin
          status = send_templated_email(templated_email_values)
          if status == "success"
            flash[:success] = TEMPLATED_EMAIL_SENT
            redirect_to plugin("email_service").emails_path and return
          end
        rescue Elektron::Errors::ApiResponse => e
          error =
            "#{I18n.t("email_service.errors.templated_email_send_error")} #{e.message}"
          Rails.logger.error error
          flash[:error] = error
        rescue Exception => e
          error =
            "#{I18n.t("email_service.errors.templated_email_send_error")} #{e.message}"
          Rails.logger.error error
          flash[:error] = error
        end
      else
        render "edit", locals: { data: { modal: true } } and return
      end
      redirect_to plugin("email_service").emails_path
    end

    private

    def templated_email_form(attributes = {})
      EmailService::Forms::TemplatedEmail.new(attributes)
    end

    def templated_email
      @templated_email = templated_email_form(templated_email_params)
    end

    def templated_email_params
      if params.include?(:templated_email)
        return(
          params.require(:templated_email).permit(
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
            :template_name,
            :template_data,
            :configuration_set_name,
            :tags,
          )
        )
      else
        return {}
      end
    end
  end
end
