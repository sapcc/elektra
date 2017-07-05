module ServiceLayerNg
  # This module implements Openstack Domain API
  module Server
    def servers(filter={},use_cache = false)
      puts "[compute-service][Server] -> servers -> GET servers/detail"

      server_data = nil
      unless use_cache
        server_data = api.compute.list_servers_detailed(filter).body['servers']
        Rails.cache.write("#{@scoped_project_id}_servers",server_data, expires_in: 2.hours)
      else
        server_data = Rails.cache.fetch("#{@scoped_project_id}_servers", expires_in: 2.hours) do
          api.compute.list_servers_detailed(filter).body['servers']
        end
      end

      api.map_to(Compute::ServerNg,server_data)
    end
  end
end