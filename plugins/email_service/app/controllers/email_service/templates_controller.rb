# frozen_string_literal: true

module EmailService
  # TemplatesController
  class TemplatesController < ::EmailService::ApplicationController
    before_action :check_pre_conditions_for_cronus
    before_action :set_template, only: %i[show edit]
    before_action :template, only: %i[new create]

    authorization_context "email_service"
    authorization_required

    def index
      @templates = templates
      items_per_page = 10
      unless @templates.empty?
        @paginatable_templates =
          Kaminari
            .paginate_array(@templates, total_count: @templates.count)
            .page(params[:page])
            .per(items_per_page)
      end
    rescue Elektron::Errors::ApiResponse, StandardError => e
      flash.now[
        :error
      ] = "#{I18n.t("email_service.errors.template_list_error")} #{e.message}"
    end

    def show
      render "show", locals: { data: { modal: true } }
    rescue Elektron::Errors::ApiResponse, StandardError => e
      flash.now[
        :error
      ] = "#{I18n.t("email_service.errors.template_show_error")} #{e.message}"
    end

    def new;end

    def edit; end

    def create
      return render action: "new", locals: { data: { modal: true } } unless @template.valid?

      status = create_email_template(@template)
      if status == "success"
        flash[:success] = "Email template #{@template.name} is saved"
        redirect_to plugin("email_service").templates_path and return
      else
        flash.now[
          :error
        ] = "#{I18n.t("email_service.errors.template_create_error")} #{status}"
        render "new", locals: { data: { modal: true } } and return
      end
    rescue Elektron::Errors::ApiResponse, StandardError => e
      flash.now[
        :error
      ] = "#{I18n.t("email_service.errors.template_create_error")} #{e.message}"
      redirect_to plugin("email_service").templates_path
    end

    def update
      @template = template_form(template_params)
      @template.name = params[:name]
      return render action: "edit", data: { modal: true } unless @template.valid?

      status = update_email_template(@template)

      if status == "success"
        flash[:success] = "Email template [#{@template.name}] is updated"
        redirect_to plugin("email_service").templates_path and return
      else
        flash.now[
          :error
        ] = "Error: #{status}; Email template [#{@template.name}] is not updated"
        render "edit", data: { modal: true }
      end
    rescue Elektron::Errors::ApiResponse, StandardError => e
      flash.now[
        :error
      ] = "#{I18n.t("email_service.errors.template_update_error")} #{e.message}"
    end

    def destroy
      status = delete_email_template(params[:name])
      flash[:success] = "Template #{params[:name]} is deleted."
      redirect_to plugin("email_service").templates_path
    rescue Elektron::Errors::ApiResponse, StandardError => e
      flash.now[:error] = "#{I18n.t("email_service.errors.template_delete_error")} #{e.message}"
    end

    private


    def set_template
      @template = find_email_template(params[:name])
    end

    def template_params
      if params.include?(:template)
        params.require(:template).permit(
          :name,
          :subject,
          :html_part,
          :text_part
        )
      else
        {}
      end
    end

    def template_form(attributes = {})
      EmailService::Template.new(attributes)
    end

    def template
      @template = template_form(template_params)
    end

  end
end
