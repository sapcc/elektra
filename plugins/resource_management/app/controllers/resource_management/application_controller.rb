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
       quotas.each do |data|
         resource_data = {}
         resource_config = ResourceManagement::Resource.get_known_resource(data.service, data.name)
         if resource_config

           usage = data.usage
           current_quota = data.current_quota
           approved_quota = data.approved_quota
           if resource_config[:display_unit]
             usage = data.usage/resource_config[:display_unit] 
             current_quota = data.current_quota/resource_config[:display_unit]
             approved_quota = data.approved_quota/resource_config[:display_unit]
           end

           usage_percent = 0
           approved_percent = 0
           if current_quota > 0
             usage_percent = ((usage.to_f / current_quota.to_f)*100).to_i
             approved_percent = ((approved_quota.to_f / current_quota.to_f)*100).to_i
           end

           if (approved_quota < current_quota and usage_percent >= approved_quota) or usage_percent >= from_usage
             resource_data[:service] = data.service
             resource_data[:name] = data.name
             resource_data[:danger_level] = danger_level
             resource_data[:quota] = {
               :approved => approved_quota,
               :current  => current_quota,
               :usage    => usage,
             }
             resource_data[:percent] = {
               :approved => approved_percent,
               :usage => usage_percent,
             }
           end

           usage_data.push(resource_data)
         end
       end
       usage_data
    end
  end
end
