# frozen_string_literal: true

module Networking
  # Implements Network Rbac actions
  class Networks::AccessController < NetworksController
    def index
      @rbacs = services.networking.rbacs(
        object_id: @network_id, object_type: 'network'
      )
      @network = services.networking.find_network(@network_id)

      rbac_target_tenant_ids = @rbacs.collect(&:target_tenant)

      @rbac_auth_projects = []
      @auth_projects = service_user.identity.cached_user_projects(
        current_user.id, domain_id: @scoped_domain_id
      ).sort_by(&:name)
      @auth_projects.each do |project|
        if project.id == @scoped_project_id ||
           rbac_target_tenant_ids.include?(project.id)
          next
        end
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

      @network = services.networking.find_network(@network_id)

      @rbac.save
    end

    def destroy
      @rbac = services.networking.new_rbac
      @rbac.id = params[:id]

      if @rbac.destroy
        flash.now[:notice] = 'Access successfully removed.'
      else
        flash.now[:error] = @rbac.errors.full_messages.to_sentence
      end

      respond_to do |format|
        format.js {}
        format.html do
          redirect_to plugin('networking').send(
            "networks_#{@network_type}_access_index_path"
          )
        end
      end
    end

    private

    def load_type
      @network_type = params.key?('private_id') ? 'private' : 'external'
      @network_id   = params["#{@network_type}_id"]
    end
  end
end
