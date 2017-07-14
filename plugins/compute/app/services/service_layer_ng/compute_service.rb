# frozen_string_literal: true

module ServiceLayerNg
  # This class implements the Openstack compute api
  class ComputeService < Core::ServiceLayerNg::Service
    include Flavor
    include HostAggregate
    include Hypervisor
    include Image
    include Keypair
    include OsInterface
    include SecurityGroup
    include Server
    include Service
    include Volume

    def available?(_action_name_sym = nil)
      api.catalog_include_service?('compute', region)
    end

    def usage(filter = {})
      debug '[compute-service] -> usage -> GET /limits'
      api.compute.show_rate_and_absolute_limits(filter).map_to(Compute::Usage)
    end

    def availability_zones
      debug '[compute-service] -> availability_zones -> GET /os-availability-zone'
      api.compute.get_availability_zone_information
         .map_to(Compute::AvailabilityZone)
    end
  end
end
