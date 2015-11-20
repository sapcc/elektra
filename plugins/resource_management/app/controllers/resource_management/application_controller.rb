module ResourceManagement
  class ApplicationController < DashboardController
    
    def index
      @critical_quotas = ResourceManagement::Resource.get_critical_quotas(@scoped_domain_id,@scoped_project_id,100)
      #raise
    end

    def resource_request
      @resource_type = params[:resource_type]
      @service = params[:service]
    end
    
    def compute
      @quotas = ResourceManagement::Resource.get_quotas(@scoped_domain_id,@scoped_project_id,"compute",100)
    end

    def manual_sync
      # services.resource_management.get_project_usage_swift("o-5ca7c76b0","p-6e6e0bc61")
      services.resource_management.sync_projects
      services.resource_management.sync_service(:object_storage)
      begin
        redirect_to :back
      rescue ActionController::RedirectBackError
        render text: "Synced!"
      end
    end

  end
end
