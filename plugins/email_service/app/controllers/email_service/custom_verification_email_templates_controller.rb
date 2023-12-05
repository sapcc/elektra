# frozen_string_literal: true

module EmailService
  class CustomVerificationEmailTemplatesController < ::EmailService::ApplicationController
    before_action :check_pre_conditions_for_cronus
    before_action :set_custom_verification_email_template, only: %i[show edit]

    authorization_context "email_service"
    authorization_required

    def index
      @custom_templates = list_custom_verification_email_templates
      items_per_page = 10

      @paginatable_templates =
        Kaminari
          .paginate_array(
            @custom_templates,
            total_count: @custom_templates.count,
          )
          .page(params[:page])
          .per(items_per_page)
    rescue Elektron::Errors::ApiResponse,
           Aws::SES::Errors::ServiceError,
           StandardError => e
      error =
        "#{I18n.t("email_service.errors.custom_email_verification_list_error")} #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    end

    def show
      render "show", locals: { data: { modal: true } }
    rescue Elektron::Errors::ApiResponse, StandardError => e
      error =
        "#{I18n.t("email_service.errors.custom_email_verification_list_error")} #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    end

    def new
      @custom_template =
        custom_verification_email_template_form(
          custom_verification_email_template_params,
        )
    end

    def create
      @custom_template =
        custom_verification_email_template_form(
          custom_verification_email_template_params,
        )

      unless @custom_template.valid?
        render "new", locals: { data: { modal: true } } and return
      end

      status = create_custom_verification_email_template(@custom_template)
      if status == "success"
        flash[
          :success
        ] = "Email custom_template #{@custom_template.template_name} is saved"
      else
        flash[:error] = status
        render "new", locals: { data: { modal: true } } and return
      end
      redirect_to plugin(
        "email_service",
      ).custom_verification_email_templates_path and return
    rescue Elektron::Errors::ApiResponse, StandardError => e
      error =
        "#{I18n.t("email_service.errors.custom_email_verification_create_error")} #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    rescue Aws::SES::Errors::LimitExceeded => e
      error =
        "#{I18n.t("email_service.errors.endcustom_email_verification_limit_error")} #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    end

    def show
      @custom_template =
        find_custom_verification_email_template(params[:template_name])
    end

    def update
      @custom_template =
        custom_verification_email_template_form(
          custom_verification_email_template_params,
        )
      unless @custom_template.valid?
        return render action: "edit", data: { modal: true }
      end

      status = update_custom_verification_email_template(@custom_template)

      if status == "success"
        flash[
          :success
        ] = "Email custom_template [#{@custom_template.template_name}] is updated"
        redirect_to plugin(
                      "email_service",
                    ).custom_verification_email_templates_path and return
      else
        error =
          "#{I18n.t("email_service.errors.custom_email_verification_update_error")} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
        render "edit", data: { modal: true }
      end
    end

    def destroy
      status = delete_custom_verification_email_template(params[:template_name])
      if status == "success"
        flash[
          :success
        ] = "Custom verification template #{params[:template_name]} is deleted."
      else
        error =
          "Unable to delete custom_template [#{params[:template_name]}] : #{status} "
        Rails.logger.error error
        flash[:error] = error
      end
      redirect_to plugin(
                    "email_service",
                  ).custom_verification_email_templates_path
    end

    private

    def custom_verification_email_template_form(attributes = {})
      EmailService::CustomVerificationEmailTemplate.new(attributes)
    end

    def set_custom_verification_email_template
      @custom_template =
        find_custom_verification_email_template(params[:template_name])
    end

    def custom_verification_email_template_params
      if params.include?(:custom_template)
        params.require(:custom_template).permit(
          :template_name,
          :from_email_address,
          :template_subject,
          :template_content,
          :success_redirection_url,
          :failure_redirection_url
        )
      else
        {}
      end
    end
  end
end
