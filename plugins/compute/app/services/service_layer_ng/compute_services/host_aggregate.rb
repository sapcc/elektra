# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module HostAggregate
      def host_aggregates(filter = {})
        api.compute.list_aggregates(filter).map_to(Compute::HostAggregate)
      end
    end
  end
end
