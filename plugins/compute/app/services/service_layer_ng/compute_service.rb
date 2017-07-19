# frozen_string_literal: true

module ServiceLayerNg
  # This class implements the Openstack compute api
  class ComputeService < Core::ServiceLayerNg::Service
    include ComputeServices::Flavor
    include ComputeServices::HostAggregate
    include ComputeServices::Hypervisor
    include ComputeServices::Image
    include ComputeServices::Keypair
    include ComputeServices::OsInterface
    include ComputeServices::SecurityGroup
    include ComputeServices::Server
    include ComputeServices::Service
    include ComputeServices::Volume

    def available?(_action_name_sym = nil)
      api.catalog_include_service?('compute', region)
    end

    def usage(filter = {})
      debug '[compute-service] -> usage -> GET /limits'
      response = api.compute.show_rate_and_absolute_limits(filter).body['limits']['absolute']
      map_to(Compute::Usage,response)
    end

    def availability_zones
      debug '[compute-service] -> availability_zones -> GET /os-availability-zone'
      api.compute.get_availability_zone_information
         .map_to(Compute::AvailabilityZone)
    end
  end
end
