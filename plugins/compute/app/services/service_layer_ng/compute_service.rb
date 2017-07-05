module ServiceLayerNg

  # This class implements the identity api
  class ComputeService < Core::ServiceLayerNg::Service
    
    include Server
    include Flavor
    include Keypair
    
    def available?(action_name_sym=nil)
      not current_user.service_url('compute',region: region).nil?
    end

    def usage(filter = {})
      debug "[compute-service] -> usage -> GET /limits"
      api.compute.show_rate_and_absolute_limits(filter).map_to(Compute::Usage)
    end

    def availability_zones
      debug "[compute-service] -> availability_zones -> GET /os-availability-zone"
      api.compute.get_availability_zone_information.map_to(Compute::AvailabilityZone)
    end

  end
end