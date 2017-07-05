module ServiceLayerNg

  # This class implements the identity api
  class ComputeService < Core::ServiceLayerNg::Service
    
    include Server
  
    def available?(action_name_sym=nil)
      not current_user.service_url('compute',region: region).nil?
    end

    def usage(filter = {})
      puts "[compute-service] -> usage -> GET /limits"
      api.compute.show_rate_and_absolute_limits(filter).map_to(Compute::UsageNg)
    end

  end
end