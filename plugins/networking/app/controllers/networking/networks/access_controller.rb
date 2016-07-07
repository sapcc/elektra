module Networking
  class Networks::AccessController < NetworksController
    def index
      @rbacs = services.networking.rbacs(object_id: @network_id, object_type: 'network')
      
      rbac_target_tenant_ids = services.networking.rbacs(object_id: @network_id, object_type: 'network').collect{|rbac| rbac.target_tenant}

      @rbac_auth_projects = []
      @user_domain_projects.each do |project| 
        next if project.id==@scoped_project_id or rbac_target_tenant_ids.include?(project.id)
        @rbac_auth_projects << "#{project.id} (#{project.name})" 
      end
    end

    def create
      @rbac = services.networking.new_rbac(params[:rbac])
      @rbac.object_id     = @network_id
      @rbac.object_type   = 'network'
      @rbac.action        = 'access_as_shared'

      if @rbac.target_tenant.include?('(')
        @rbac.target_tenant = @rbac.target_tenant.split('(').first.strip
      end

      if @rbac.save
        render action: :create
        #redirect_to plugin('networking').send("networks_#{@network_type}_access_index_path", @network_id)
      else
        rbac_target_tenant_ids = services.networking.rbacs(object_id: @network_id, object_type: 'network').collect{|rbac| rbac.target_tenant}

        @rbac_auth_projects = []
        @user_domain_projects.each do |project| 
          next if project.id==@scoped_project_id or rbac_target_tenant_ids.include?(project.id)
          @rbac_auth_projects << "#{project.id} (#{project.name})" 
        end
        
        render action: :new
      end
    end

    def destroy
      @rbac = services.networking.find_rbac(params[:id]) rescue nil

      if @rbac
        if @rbac.destroy
          flash.now[:notice] = 'Access successfully removed.'
        else
          flash.now[:error] = @rbac.errors.full_messages.to_sentence
        end
      else
        flash.now[:error] = "Could not find this item."
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
