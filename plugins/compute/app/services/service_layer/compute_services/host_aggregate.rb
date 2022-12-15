# frozen_string_literal: true

module ServiceLayer
  module ComputeServices
    # This module implements Openstack Domain API
    module HostAggregate
      def host_aggregates(filter = {})
        elektron_compute
          .get("os-aggregates", filter)
          .map_to("body.aggregates") do |data|
            Compute::HostAggregate.new(self, data)
          end
      end
    end
  end
end
