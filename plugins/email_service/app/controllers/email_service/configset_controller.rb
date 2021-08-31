module EmailService
  class ConfigsetController < ::EmailService::ApplicationController
    include AwsSesHelper
    include EmailHelper

    def index
      @configsets = get_configset
      items_per_page = 10
      @paginatable_array = Kaminari.paginate_array(@configsets, total_count: @configsets.count).page(params[:page]).per(items_per_page)
      @id = 0

    end
    

    def new_configset

    end

    def show_configset
      name = params[:name] if params[:name]
      @configset_description = describe_configset(name)
    end

    def create_configset
      # logger.debug "CRONUS: DEBUG: configset_params: #{params.inspect}"
      name = params[:configset][:name] if params[:configset][:name]
      status = configset_create(name)
      # logger.debug "CRONUS: DEBUG: create_configset (controller): #{status}"
      if status == "success"
        msg = "Config Set: #{name} is created"
        flash[:success] = msg
      else
        msg = "Config Set #{name} is not created : #{status}"
        flash[:warning] = msg
      end
      redirect_to plugin('email_service').configset_path
    end

    def destroy_configset
      status = ""
      name = params[:name] ?  params[:name] : ""
      # logger.debug "CRONUS: DEBUG: params name #{name}"

      status = configset_destroy(name) if name

      if status == "success"
        msg = "Config Set: #{name} is removed"
        flash[:success] = msg
      else
        msg = "Config Set #{name} is not removed : #{status}"
        flash[:warning] = msg
      end
     
      redirect_to plugin('email_service').configset_path

    end

  end
end