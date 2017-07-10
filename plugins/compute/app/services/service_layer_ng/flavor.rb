module ServiceLayerNg
  # This module implements Openstack Domain API
  module Flavor

    def flavors(filter={})
      debug "[compute-service][Flavor] -> flavors -> GET /flavors/detail"
      api.compute.list_flavors_with_details(filter).map_to(Compute::Flavor)
    end
    
    def flavor(flavor_id,use_cache = false)
      debug "[compute-service][Flavor] -> flavor -> GET /flavors/#{flavor_id}"

      flavor_data = nil
      unless use_cache
        flavor_data = api.compute.show_flavor_details(flavor_id).data
        Rails.cache.write("server_flavor_#{flavor_id}",flavor_data, expires_in: 24.hours)
      else
        flavor_data = Rails.cache.fetch("server_flavor_#{flavor_id}", expires_in: 24.hours) do
          api.compute.show_flavor_details(flavor_id).data
        end
      end

      return nil if flavor_data.nil?
      map_to(Compute::Flavor,flavor_data)
    end

  end
end