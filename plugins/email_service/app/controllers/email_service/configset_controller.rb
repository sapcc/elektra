module EmailService
  class ConfigsetController < ::EmailService::ApplicationController
    before_action :restrict_access

    authorization_context 'email_service'
    authorization_required
    
    def index
      creds = get_ec2_creds
      if creds.error.empty?
        @configsets = get_configset
        items_per_page = 10
        @paginatable_array = Kaminari.paginate_array(@configsets, total_count: @configsets.count).page(params[:page]).per(items_per_page)
        @id = 0
      else
        flash[:error] = creds.error
      end
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end
    
    def new_configset; end


    def show_configset
      name = params[:name] if params[:name]
      @configset_description = describe_configset(name)
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
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
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
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

    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

  end
end
