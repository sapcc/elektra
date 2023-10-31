# frozen_string_literal: true

module EmailService
  # PlainEmailsController

  class PlainEmailsController < ::EmailService::ApplicationController
    before_action :check_pre_conditions_for_cronus
    before_action :plain_email, only: %i[new edit]

    authorization_context 'email_service'
    authorization_required

    PLAIN_EMAIL_SENT =
      I18n.t('email_service.messages.plain_email_sent').to_s.freeze

    def new
      @source_types = ::EmailService::Email.source_types
    end

    def edit; end

    def create
      @source_types = ::EmailService::Email.source_types
      @plain_email = plain_email_form(plain_email_params)

      # Assign 'source', 'reply_to_addr' and 'return_path' based on form inputs
      case @plain_email.source_type
      when 'domain'
        if @plain_email.source.nil?
          @plain_email.source = @plain_email.source_domain_name_part.nil? ? "test@#{@plain_email.source_domain}" : "#{@plain_email.source_domain_name_part}@#{@plain_email.source_domain}"
        end
      when 'email'
        @plain_email.source = @plain_email.source_email
      end

      @plain_email.reply_to_addr.nil? && @plain_email.reply_to_addr = @plain_email.source
      @plain_email.return_path.nil? && @plain_email.return_path = @plain_email.source

      plain_email_values = @plain_email.process(EmailService::PlainEmail)

      begin
        if @plain_email.valid?
          status = send_plain_email(plain_email_values)
          unless status.include?('success')
            Rails.logger.error status
            flash[:error] = status
            render 'edit', locals: { data: { modal: true } }
          end
          redirect_to plugin('email_service').emails_path
        else
          render action: 'edit', data: { modal: true }
        end
      rescue Elektron::Errors::ApiResponse, StandardError => e
        error =
          "#{I18n.t('email_service.errors.plain_email_send_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      end
      flash[:success] = PLAIN_EMAIL_SENT
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
          :configuration_set_name
        )
      else
        {}
      end
    end
  end
end
