module EmailService
  class ConfigsetsController < ::EmailService::ApplicationController
    before_action :restrict_access

    authorization_context 'email_service'
    authorization_required

    def index
      creds = get_ec2_creds
      if creds.error.empty?
        next_token, @configsets = list_configsets
        items_per_page = 10
        @paginatable_configsets = Kaminari.paginate_array(@configsets, total_count: @configsets.count).page(params[:page]).per(items_per_page)
        # @id = 0
      else
        flash[:error] = creds.error
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500- : Error: #{e.message}"
    end

    def new;end

    def show
      @id = params[:id] if params[:id]
      @name = params[:name] if params[:name]
      @configset_description = describe_configset(@name)
      #<struct Aws::SES::Types::DescribeConfigurationSetResponse configuration_set=#<struct Aws::SES::Types::ConfigurationSet name="ABC">, event_destinations=[], tracking_options=nil, delivery_options=nil, reputation_options=nil>
      render "show", locals: { data: { modal: true } }
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: --500-- : Error: #{e.message}"
    end

    def create
      status = ""
      @configset = new_configset(configset_params)
      if @configset.errors?
        flash.now[:error] = @configset.errors
        render 'new' and return
      else
        status = store_configset(@configset)
        if status == "success"
          flash[:success] = "Configset #{@configset.name} is saved"
          redirect_to plugin('email_service').configsets_path
        else
          flash.now[:warning] = status
          render 'new' and return
        end 
      end
      redirect_to plugin('email_service').configsets_path
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
      
    end

    def destroy
      
      status = ""
      name = params[:name] ?  params[:name] : ""
      configset = find_configset(params[:name])
      status = delete_configset(configset.name) if configset
      if status == "success"
        msg = "Config Set: #{name} is removed"
        flash[:success] = msg
        redirect_to plugin('email_service').configsets_path
      else
        msg = "Config Set #{name} is not removed : #{status}"
        flash[:error] = msg
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e}"
      redirect_to plugin('email_service').configsets_path
    end


    def edit
      @configset = find_configset(params[:name])
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def update
      status = ""
      configset = find_configset(params[:name])
      # Add code to modify with other props here.
      redirect_to plugin('email_service').configsets_path
    end

    private

      def set_configset
        @configset = find_configset(params[:name])
      end
      def configset_params
        params.require(:configset).permit(:name)
      end

  end
end
