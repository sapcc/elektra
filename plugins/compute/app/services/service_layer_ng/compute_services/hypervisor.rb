# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module Hypervisor
      def hypervisors(filter = {})
        api.compute.list_hypervisors_details(filter).map_to(Compute::Hypervisor)
      end

      def find_hypervisor(id)
        return nil if id.blank?
        api.compute.show_hypervisor_details(id).map_to(Compute::Hypervisor)
      end

      def hypervisor_servers(hypervisor_hostname_pattern)
        # in that case we do not use the map_to directly because the api
        # client fails to get the correct data from the response
        hypervisors = api.compute.list_hypervisor_servers(
          hypervisor_hostname_pattern
        ).body['hypervisors']
        map_to(Compute::HypervisorServer, hypervisors.first['servers'])
      end
    end
  end
end
