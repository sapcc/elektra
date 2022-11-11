module EmailService
  class CustomVerificationEmailTemplatesController < ::EmailService::ApplicationController

    before_action :check_ec2_creds_cronus_status
    before_action :check_verified_identity

    before_action :set_custom_verification_email_template, only: %i[show edit]

    authorization_context 'email_service'
    authorization_required

    def index

      @custom_templates = custom_templates

      items_per_page = 10
      if @custom_templates && @custom_templates.count > 0
        @paginatable_templates =  Kaminari.paginate_array(@custom_templates, total_count: @custom_templates.count).page(params[:page]).per(items_per_page)
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: (INDEX) #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: (INDEX) 500 : Error: #{e.message}"
    end

    def show
      render "show", locals: { data: { modal: true } }
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: (SHOW) #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: (SHOW) 500 : Error: #{e.message}"
    end

    def new
      @custom_template = custom_verification_email_template_form(custom_verification_email_template_params)
    end

    def edit

    end

    def create
      @custom_template = custom_verification_email_template_form(custom_verification_email_template_params)

      if @custom_template.valid?
        status = create_custom_verification_email_template(@custom_template)
        if status == "success"
          flash[:success] = "eMail custom_template #{@custom_template.template_name} is saved"
          redirect_to plugin('email_service').custom_verification_email_templates_path and return
        else
          flash[:error] = status
          render "new", locals: {data: {modal: true} } and return
        end
      else
        render "new", locals: {data: {modal: true} } and return
      end
      redirect_to plugin('email_service').custom_verification_email_templates_path
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: (CREATE - E) #{e.code} : Error: #{e.message}"
      rescue Aws::SES::Errors::LimitExceeded => e
        flash.now[:error] = "#{e.code} : Error: #{e.message}; \n Maximum Custom verification email templates are only 50."
      rescue Exception => e
        flash[:error] = "Status Code: (CREATE - G) 500 : Error: #{e.message}"

    end

    def show
      @custom_template = find_custom_verification_email_template(params[:template_name])
    end

    def update
      @custom_template = custom_verification_email_template_form(custom_verification_email_template_params)

      if @custom_template.valid?
        # update the original custom_template
        status = update_custom_verification_email_template(@custom_template)
      else
        return render action: 'edit', data: {modal: true}
      end
      if status == "success"
        flash[:success] = "eMail custom_template [#{@custom_template.template_name}] is updated"
        redirect_to plugin('email_service').custom_verification_email_templates_path and return
      else
        flash.now[:error] = "Error: #{status}; eMail custom_template [#{@custom_template.template_name}] is not updated"
        render 'edit', data: {modal: true}
      end
    end

    def destroy

      status = delete_custom_verification_email_template(params[:template_name])
      if status == "success"
        flash[:success] = "Custom verification template #{params[:template_name]} is deleted."
      else
        flash[:warning] = "Unable to delete custom_template [#{params[:template_name]}] : #{status} "
      end
      redirect_to plugin('email_service').custom_verification_email_templates_path
    end

    private

    def custom_verification_email_template_form(attributes={})
      EmailService::CustomVerificationEmailTemplate.new(attributes)
    end

    def set_custom_verification_email_template
      @custom_template = find_custom_verification_email_template(params[:template_name])
    end

    def custom_verification_email_template_params
      if params.include?(:custom_template)
        return params.require(:custom_template).permit(:template_name, :from_email_address, :template_subject, :template_content, :success_redirection_url, :failure_redirection_url )
      else
        return {}
      end
    end

  end
end
