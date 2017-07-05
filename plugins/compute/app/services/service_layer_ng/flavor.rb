module ServiceLayerNg
  # This module implements Openstack Domain API
  module Flavor

    def flavors(filter={})
      debug "[compute-service][Flavor] -> flavors -> GET /flavors/detail"
      api.compute.list_flavors_with_details(filter).map_to(Compute::Flavor)
    end

  end
end