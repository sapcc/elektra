module ResourceManagement
  class Resource < ActiveRecord::Base
      #validates [:service, :name], presence: true
      class << self
        def get_critical_quotas(scoped_domain_id,scoped_project_id,danger_level)
          quotas = where(:domain_id => scoped_domain_id, :project_id => scoped_project_id)
          calculate_quotas_usage(quotas,100,danger_level)
        end

        def get_quotas(scoped_domain_id,scoped_project_id,service,danger_level)
          quotas = where(:domain_id => scoped_domain_id, :project_id => scoped_project_id, :service => service)
          calculate_quotas_usage(quotas, 0, danger_level)
        end
  
        private
  
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
      end
  end
end
