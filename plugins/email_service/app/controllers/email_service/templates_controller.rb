module EmailService
  class TemplatesController < ::EmailService::ApplicationController
    before_action :restrict_access

    authorization_context 'email_service'
    authorization_required

    def index
      creds = get_ec2_creds
      if creds.error.empty?
        @templates = get_all_templates
        items_per_page = 10
        @paginatable_templates = Kaminari.paginate_array(@templates, total_count: @templates.count).page(params[:page]).per(items_per_page)
        @id = 0
      else
        flash[:error] = creds.error
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def show
      @template = find_template(params[:name])
      render "show", locals: { data: { modal: true } }
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def new; end

    def edit
      @template = find_template(params[:name])
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def update
      status = ""
      template = find_template(params[:name])
      template_new = new_template(template_params)

      if template_new.errors?
        flash[:error] = @template.errors.first[:message]
        redirect_to 'edit', data: {modal: true}
      elsif template 
        status = update_template(template.name, template_new.subject, template_new.html_part, template_new.text_part)
      end

      if status == "success"
        flash[:success] = "eMail template [#{template.name}] is updated" 
      else 
        flash[:error] = "Error: #{status}; eMail template [#{template.name}] is not updated" 
      end
        redirect_to plugin('email_service').templates_path
    end

    def create
      status = ""
      @template = new_template(template_params)
      if @template.errors?
        flash.now[:error] = @template.errors#.first[:message]
        render 'new' and return
      else
        status = store_template(@template)
        if status == "success"
          flash[:success] = "eMail template #{@template.name} is saved"
        else
          flash.now[:warning] = status
          render 'new' and return
        end 
      end
      redirect_to plugin('email_service').templates_path
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def destroy
      status = delete_template(params[:name])
      if status == "success"
        flash[:success] = "Template #{params[:name]} is deleted."
      else
        flash[:warning] = "Unable to delete template [#{params[:name]}] : #{status} "
      end
      redirect_to plugin('email_service').templates_path
    end

    private

      def set_template
        @template = find_template(params[:name])
      end
      def template_params
        params.require(:templ).permit(:name, :subject, :html_part, :text_part)
      end
  end
end
