module EmailService
  class TemplatesController < ::EmailService::ApplicationController

    before_action :check_ec2_creds_cronus_status
    before_action :set_template, only: %i[new show edit]

    authorization_context 'email_service'
    authorization_required

    def index
      @templates = templates
      items_per_page = 10
      @paginatable_templates  = Kaminari.paginate_array(@templates, total_count: @templates.count).page(params[:page]).per(items_per_page)
      rescue Elektron::Errors::ApiResponse => e
        flash.now[:error] = "#{I18n.t('email_service.errors.template_list_error')} #{e.message}"
      rescue Exception => e
        flash.now[:error] = "#{I18n.t('email_service.errors.template_list_error')} #{e.message}"
    end

    def show
      render "show", locals: { data: { modal: true } }
      rescue Elektron::Errors::ApiResponse => e
        flash.now[:error] = "#{I18n.t('email_service.errors.template_show_error')} #{e.message}"
      rescue Exception => e
        flash.now[:error] = "#{I18n.t('email_service.errors.template_show_error')} #{e.message}"
    end

    def new;end

    def edit;end

    def create
      @template = template_form(template_params)
      if @template.valid?
        status = store_template(@template)
        if status == "success"
          flash[:success] = "eMail template #{@template.name} is saved"
          redirect_to plugin('email_service').templates_path and return
        else
          flash.now[:error] = flash.now[:error] = "#{I18n.t('email_service.errors.template_create_error')} #{status}"
          render "new", locals: {data: {modal: true} } and return
        end
      else
        render "new", locals: {data: {modal: true} } and return
      end
      rescue Elektron::Errors::ApiResponse => e
        flash.now[:error] = "#{I18n.t('email_service.errors.template_create_error')} #{e.message}"
      rescue Exception => e
        flash.now[:error] = "#{I18n.t('email_service.errors.template_create_error')} #{e.message}"
      redirect_to plugin('email_service').templates_path
    end


    def update

      @template = template_form(template_params)
      @template.name = params[:name]
      form_params = template_params
      if @template.valid?
        status = update_template(@template.name, @template.subject, @template.html_part, @template.text_part)
      else
        return render action: 'edit', data: {modal: true}
      end
      if status == "success"
        flash[:success] = "eMail template [#{@template.name}] is updated"
        redirect_to plugin('email_service').templates_path and return
      else
        flash.now[:error] = "Error: #{status}; eMail template [#{@template.name}] is not updated"
        render 'edit', data: {modal: true}
      end
      rescue Elektron::Errors::ApiResponse => e
        flash.now[:error] = "#{I18n.t('email_service.errors.template_update_error')} #{e.message}"
      rescue Exception => e
        flash.now[:error] = "#{I18n.t('email_service.errors.template_update_error')} #{e.message}"
        
    end

    def destroy

      status = delete_template(params[:name])
      if status == "success"
        flash[:success] = "Template #{params[:name]} is deleted."
      else
        flash[:warning] = "Unable to delete template [#{params[:name]}] : #{status} "
      end
      redirect_to plugin('email_service').templates_path
      rescue Elektron::Errors::ApiResponse => e
        flash.now[:error] = "#{I18n.t('email_service.errors.template_delete_error')} #{e.message}"
      rescue Exception => e
        flash.now[:error] = "#{I18n.t('email_service.errors.template_delete_error')} #{e.message}"
        
    end

    private

    def template_form(attributes={})
      EmailService::Template.new(attributes)
    end

    def set_template
      @template = find_template(params[:name])
    end

    def template_params
      if params.include?(:template)
        return params.require(:template).permit(:name, :subject, :html_part, :text_part)
      else
        return {}
      end
    end

  end
end
