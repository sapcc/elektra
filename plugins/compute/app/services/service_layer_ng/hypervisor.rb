module ServiceLayerNg
  # This module implements Openstack Domain API
  module Hypervisor

    def hypervisors(filter = {})
      debug "[compute-service][Hypervisor] -> hypervisors -> GET /os-hypervisors/detail"
      api.compute.list_hypervisors_details(filter).map_to(Compute::Hypervisor)
    end

    def find_hypervisor(id)
      debug "[compute-service][Hypervisor] -> find_hypervisor -> GET /os-hypervisors/#{id}"
      return nil if id.blank?
      api.compute.show_hypervisor_details(id).map_to(Compute::Hypervisor)
    end

    def hypervisor_servers(hypervisor_hostname_pattern)
      debug "[compute-service][Hypervisor] -> hypervisor_servers -> GET /os-hypervisors/#{hypervisor_hostname_pattern}/servers"
      # in that case we do not use the map_to directly because the api client fails to 
      # get the correct data from the response
      response = api.compute.list_hypervisor_servers(hypervisor_hostname_pattern)
      map_to(Compute::HypervisorServer,response.body['hypervisors'].first['servers'])
    end

  end
end