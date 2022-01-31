module EmailService
  class ConfigsetsController < ::EmailService::ApplicationController
    before_action :restrict_access

    before_action :set_configset, only: %i[edit, destroy, update]
    authorization_context 'email_service'
    authorization_required

    def index
      # next_token, @configsets = list_configsets
      items_per_page = 10
      @paginatable_configsets = Kaminari.paginate_array(configsets, total_count: configsets.count).page(params[:page]).per(items_per_page)
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500: Error: #{e.message}"
    end

    # current
    def new; end

    def create
      status = ""
      @configset = new_configset(configset_params)
      if !@configset.valid?
        render 'edit', local: {configset: @configset } and return
      else
        status = store_configset(@configset)
        if status == "success"
          flash[:success] = "Configset #{@configset.name} is saved"
          redirect_to plugin('email_service').configsets_path # and return
        else
          flash.now[:warning] = status
          render 'edit', local: {configset: @configset } and return
        end 
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
      redirect_to plugin('email_service').configsets_path
    end


    def show
      @id = params[:id] if params[:id]
      @name = params[:name] if params[:name]
      @configset_description = describe_configset(@name)
      render "show", locals: { data: { modal: true } }
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
      else
        msg = "Config Set #{name} is not removed : #{status}"
        flash[:error] = msg
      end
      redirect_to plugin('email_service').configsets_path and return
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e}"
      
    end


    def edit
    end

    def update
      # # Add code to modify with other props here.
      # redirect_to plugin('email_service').configsets_path
    end

    private

      def set_configset
        @configset = find_configset(params[:name])
      end

      def configset_params
        params.require(:configset).permit(:name, :event_destinations)
      end

  end
end
