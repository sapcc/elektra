module EmailService
  class TemplatesController < ::EmailService::ApplicationController

    helper :all

    def index
      @templates = list_templates
    end

    def show
      @template = find_template_by_name(params[:name])
      render "show", locals: { data: { modal: true } }
    end

    def new; end

    def edit
    end

    def create
      status = ""
      @template = new_template(template_params)
      if @template.errors?
        flash[:warning] = @template.errors.first[:message]
        # TODO - fix render 'edit' form
        # render 'edit' and return # , locals: { data: { modal: true } } and return
      else
        status = store_template(@template)
        if status == "success"
          flash[:success] = "eMail template is saved"
          
        else
          flash.now[:warning] = status
          # TODO - fix render 'edit' form
          # render 'edit' and return #, locals: { data: { modal: true } } and return
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

      def template_params
        params.require(:template).permit(:name, :subject, :html_part, :text_part)
      end

  end
end
