module ServiceLayerNg
  # This module implements Openstack Domain API
  module Server

    def new_server(params={})
      # this is used for inital create server dialog
      debug "[compute-service][Server] -> new_server"
      Compute::Server.new(params)
    end

    def servers(filter={},use_cache = false)
      debug "[compute-service][Server] -> servers -> GET servers/detail"

      server_data = nil
      unless use_cache
        server_data = api.compute.list_servers_detailed(filter).body['servers']
        Rails.cache.write("#{@scoped_project_id}_servers",server_data, expires_in: 2.hours)
      else
        server_data = Rails.cache.fetch("#{@scoped_project_id}_servers", expires_in: 2.hours) do
          api.compute.list_servers_detailed(filter).body['servers']
        end
      end

      api.map_to(Compute::Server,server_data)
    end

    def find_server(id)
      debug "[compute-service][Server] -> find_server -> GET /servers/#{id}"
      return nil if id.empty?
      api.compute.show_server_details(id).map_to(Compute::Server)
    end
    
  end
end