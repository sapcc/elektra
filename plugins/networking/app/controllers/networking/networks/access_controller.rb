module Networking
  class Networks::AccessController < NetworksController
    def index
      @rbacs = services.networking.rbacs(object_id: @network_id, object_type: 'network')
    end

    def new
      @rbac = services.networking.rbac
    end

    def create
      create_params = params['access']
      # fallback to selected project on disabled js
      @project_id = create_params['project_id'] ? create_params['project_id'] : create_params['auth_project_id']

      @rbac = services.networking.rbac

      @rbac.object_id     = @network_id
      @rbac.object_type   = 'network'
      @rbac.target_tenant = @project_id
      @rbac.action        = 'access_as_shared'

      if @rbac.save
        flash[:notice] = 'Access successfully created.'
        render action: :create
        #redirect_to plugin('networking').send("networks_#{@network_type}_access_index_path", @network_id)
      else
        flash.now[:error] = @rbac.errors.full_messages.to_sentence
        render action: :new
      end
    end

    def destroy
      @rbac = services.networking.rbac(params[:id]) rescue nil

      if @rbac
        if @rbac.destroy
          flash[:notice] = 'Access successfully removed.'
        else
          flash[:error] = @rbac.errors.full_messages.to_sentence
        end
      end

      respond_to do |format|
        format.js {}
        format.html { redirect_to plugin('networking').send("networks_#{@network_type}_access_index_path") }
      end
    end

    private

    def load_type
      @network_type = params.key?('private_id') ? 'private'.freeze : 'external'.freeze
      @network_id   = params["#{@network_type}_id"]
    end
  end
end
