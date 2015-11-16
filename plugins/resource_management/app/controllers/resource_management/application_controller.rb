module ResourceManagement
  class ApplicationController < DashboardController
    before_action :get_usage_data, only: [:compute,:storage,:network]
    
    def index
    end

    def resource_request
      @resource_type = params[:resource_type]
      @level = params[:level]
    end
    
    def compute
      puts "COMPUTE QUOTA"
      @used_aquotas = { :core => { :approved => 18, :current => 20, :used => 19, }}
    end
    private

    def calculate_quotas(quotas,usage)
       used_quotas = {}
       quotas.delete('id') if quotas
       quotas.keys.sort.each do |key|
         max = quotas[key]
         # check for unlimited
         next if max == -1
         current_use = usage[key]
         unless current_use.blank?
            percent_use = ((current_use.to_f / max.to_f) * 100).to_i
            used_quotas[key] = { :limit => max, :used => current_use, :percent => percent_use }
         end
       end
       puts "CALCULATE QUOTAS"
       puts used_quotas
       used_quotas
    end
    
    def get_usage_data
    end

  end
end
