module ResourceManagement
  class ApplicationController < DashboardController
    
    def index
      @critical_quotas = get_critical_quotas()
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


    private

    def get_critical_quotas(danger_level = 100)
      quotas = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => @scoped_project_id)
      calculate_quotas_usage(quotas,100,danger_level)
    end

    def get_quotas(service,danger_level = 100)
      quotas = ResourceManagement::Resource.where(:domain_id => @scoped_domain_id, :project_id => @scoped_project_id, :service => service)
      calculate_quotas_usage(quotas, 0, danger_level)
    end

    def calculate_quotas_usage(quotas,from_usage = 0,danger_level = 100)
       usage_data = []
       # danger: approved = usage
       #         danger_level = usage
       quotas.each do |data|
         resource_data = {}
         usage_percent = ((data.usage.to_f / data.current_quota.to_f)*100).to_i
         if (data.approved_quota < data.current_quota and usage_percent >= data.approved_quota) or usage_percent >= from_usage
            resource_data[:service] = data.service
            resource_data[:name] = data.name
            resource_data[:danger_level] = danger_level
            resource_data[:quota] = {
                :approved => data.approved_quota,
                :current => data.current_quota,
                :usage => data.usage,
            }
            resource_data[:percent] = {
                :approved => ((data.approved_quota.to_f / data.current_quota.to_f)*100).to_i,
                :usage => usage_percent,
            }
         end
         usage_data.push(resource_data)
       end
       usage_data
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
