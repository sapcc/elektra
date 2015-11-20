module ResourceManagement
  class ApplicationController < DashboardController

    def index
      # resources are critical if they have a quota, and either one of the quotas is 95% used up
      @resources = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => @scoped_project_id).
        where("(current_quota > 0 OR approved_quota > 0) AND (usage > 0.95 * approved_quota OR usage > 0.95 * current_quota)")
    end

    def resource_request
      @resource_type = params[:resource_type]
      @service = params[:service]
    end

    def compute
      @compute_quotas = get_quotas("compute")
    end

    def network
      @network_quotas = get_quotas("network")
    end

    def storage
      @block_storage_quotas = get_quotas("block_storage")
      @object_storage_quotas = get_quotas("object_storage")
    end

    def manual_sync
      service = services.resource_management
      service.sync_domains
      ResourceManagement::Resource.pluck('DISTINCT domain_id, project_id').each { |d,p| service.sync_project(d,p) }
      begin
        redirect_to :back
      rescue ActionController::RedirectBackError
        render text: "Synced!"
      end
    end

    private

    def get_quotas(service)
      ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => @scoped_project_id, :service => service)
    end

  end
end
