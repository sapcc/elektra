module EmailService
  class TemplatesController < ::EmailService::ApplicationController
    include AwsSesHelper
    include EmailHelper
    include TemplateHelper
    # before_action :template_form_attr, only: %i[new create]

    helper :all

    # authorization_context 'email_service'
    # authorization_required except: %i[]

    def index
      @templates = list_templates
      # flash.now[:success] = " Template Size : #{@templates.size} "

      # logger.debug "CRONUS: DEBUG: CONTROLLER: @templates inspect : #{@templates.inspect}"
      # @templates.each do |template|
      #   logger.debug "CRONUS: DEBUG: CONTROLLER : template[:id] : #{template[:id]}"
      #   logger.debug "CRONUS: DEBUG: CONTROLLER : template[:name] : #{template[:name]}"
      #   logger.debug "CRONUS: DEBUG: CONTROLLER : template[:subject] : #{template[:subject]}"
      #   logger.debug "CRONUS: DEBUG: CONTROLLER : template[:html_part] : #{template[:html_part]}"
      # end
    end

    def show
      @templates = list_templates
      @template = find_template_by_name(params[:name])
      # logger.debug "CRONUS: DEBUG: t-controller show @template.inspect #{@template.inspect}"
      # @template = services.email_service.find_template(params[:id])
      # # get the user name from the openstack id if available
      # user = service_user.identity.find_user(@template.creator_id)
      # @user = user ? user.name : @template.creator_id
    end

    def new
      
    end

    def create
      msg = ""
      @template = new_template(template_params)

      status = create_template(@template)
      # logger.debug "CRONUS: DEBUG (on create): @template.inspect : #{@template.inspect}"
      if status == "success"
        msg = "eMail template is saved"
        redirect_to plugin('email_service').templates_path, notice: msg
      else 
        msg = "error occured: #{status}"
        redirect_to plugin('email_service').edit_template_path, alert: msg
      end
      logger.debug "CRONUS DEBUG: #{msg}"
      # flash.now[:alert] = msg 

      # flash.now[:success] = " Template Size : #{@templates.size} "

      # @template = services.email_service.new_template(template_params)
      # if @template.save
      #   redirect_to plugin('email_service').templates_path
      # else
      #   render action: :new
      # end
    end

    def destroy
      msg = ""

      status = delete_template(params[:name])
      if status == "success"
        msg = "Template #{params[:name]} deleted successfully"
        redirect_to plugin('email_service').templates_path
      else
        msg = "Unable to delete template [#{params[:name]}] : #{status} "
      end
      # # delete template
      # @template = services.email_service.new_template
      # @template.id = params[:id]

      # if @template.destroy
      #   flash.now[:success] = "template #{params[:id]} was successfully removed."
      # end
      # # grap a new list of secrets
      # @templates = templates

      # # render
      # render action: :index
    end

    private

    def templates
      # page = params[:page] || 1
      # per_page = params[:limit] || 10
      # offset = (page.to_i - 1) * per_page
      # result = services.email_service.templates(
      #   sort: 'created:desc', limit: per_page, offset: offset
      # )
      # Kaminari.paginate_array(
      #   result[:items], total_count: result[:total]
      # ).page(page).per(per_page)
    end

    def template_form_attr
      # @template = services.email_service.new_template   
    end

    def template_params
      unless params['template'].blank?
        template = params.clone.fetch('template', {})
        return template
      end
      return {}
    end

  end
end
