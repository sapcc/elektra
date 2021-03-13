module EmailService
  class TemplatesController < ::EmailService::ApplicationController

    before_action :template_form_attr, only: %i[new create]

    helper :all

    # authorization_context 'email_service'
    # authorization_required except: %i[]

    def index
      @templates = templates
    end

    def show
      @template = services.email_service.find_template(params[:id])
      # get the user name from the openstack id if available
      user = service_user.identity.find_user(@template.creator_id)
      @user = user ? user.name : @template.creator_id
    end

    def new; end

    def create
      @template = services.email_service.new_template(template_params)
      if @template.save
        redirect_to plugin('email_service').templates_path
      else
        render action: :new
      end
    end

    def destroy
      # delete template
      @template = services.email_service.new_template
      @template.id = params[:id]

      if @template.destroy
        flash.now[:success] = "template #{params[:id]} was successfully removed."
      end
      # grap a new list of secrets
      @templates = templates

      # render
      render action: :index
    end

    private

    def templates
      page = params[:page] || 1
      per_page = params[:limit] || 10
      offset = (page.to_i - 1) * per_page
      result = services.email_service.templates(
        sort: 'created:desc', limit: per_page, offset: offset
      )
      Kaminari.paginate_array(
        result[:items], total_count: result[:total]
      ).page(page).per(per_page)
    end

    def template_form_attr
      @template = services.email_service.new_template   
    end

    def template_params
      unless params['template'].blank?
        template = params.clone.fetch('template', {})
        # remove if blank
        template.delete_if { |key, value| value.blank? }
        return template
      end
      return {}
    end

  end
end
