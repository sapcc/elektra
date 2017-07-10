module ServiceLayerNg
  # This module implements Openstack Domain API
  module HostAggregate

    def host_aggregates(filter = {})
      debug "[compute-service][HostAggregate] -> host_aggregates -> GET /os-aggregates"
      api.compute.list_aggregates(filter).map_to(Compute::HostAggregate)
    end

  end
end