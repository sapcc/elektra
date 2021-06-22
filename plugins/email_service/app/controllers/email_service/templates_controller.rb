module EmailService
  class TemplatesController < ::EmailService::ApplicationController

    helper :all

    def index
      if params[:next_token]
        # @current_token, 
        @next_token, @templates = list_templates(params[:next_token])
      else
        # @current_token, 
        @next_token, @templates = list_templates
      end
      # TODO
      # Implement fetching more than 10 items
    end

    def show
      @template = find_template_by_name(params[:name])
      render "show", locals: { data: { modal: true } }
    end

    def new; end

    def edit
      @template = find_template_by_name(params[:name])
    end

    def modify
      status = ""
      template_old = find_template_by_name(params[:name])
      logger.debug "CONTROLLER: Name: #{template_old.name} Subject: #{template_old.subject} HTML: #{template_old.html_part} TEXT: #{template_old.text_part}"
      template_new = new_template(template_params)
      if template_new.errors?
        flash[:warning] = @template.errors.first[:message]
        redirect_to 'edit', data: {modal: true}
      else
        status = modify_template(template_old, template_new)
        if status == "success"
          flash[:success] = "eMail template [#{template_new.name}] is modified"
        end
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
        @template = find_template_by_name(params[:name])
      end
      def template_params
        params.require(:templ).permit(:name, :subject, :html_part, :text_part)
      end
  end
end
