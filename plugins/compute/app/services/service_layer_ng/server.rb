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

    def create_server(params={})
      debug "[compute-service][Server] -> create_server -> POST /serers"
      debug "[compute-service][Server] -> create_server -> Parameter: #{params}"

      name       = params.delete("name")
      flavor_ref = params.delete("flavorRef")
      params["server"] = {
        'flavorRef' => flavor_ref,
        'name'      => name
      }

      image_ref = params.delete("imageRef")
      params['server']['imageRef'] = image_ref if image_ref

      params["max_count"]=params["max_count"].to_i if params["max_count"]
      params["min_count"]=params["min_count"].to_i if params["min_count"]
      if networks=params.delete("networks")
       nics=networks.collect { |n| {'net_id' => n["id"], 'v4_fixed_ip' => n['fixed_ip'], 'port_id' => n['port']} }

       if nics
        params['server']['networks'] =
          Array(nics).map do |nic|
            neti = {}
            neti['uuid']     = (nic['net_id']      || nic[:net_id])      unless (nic['net_id']      || nic[:net_id]).nil?
            neti['fixed_ip'] = (nic['v4_fixed_ip'] || nic[:v4_fixed_ip]) unless (nic['v4_fixed_ip'] || nic[:v4_fixed_ip]).nil?
            neti['port']     = (nic['port_id']     || nic[:port_id])     unless (nic['port_id']     || nic[:port_id]).nil?
            neti
          end
       end
      end

      api.compute.create_server(params)

    end

    def find_server(id)
      debug "[compute-service][Server] -> find_server -> GET /servers/#{id}"
      return nil if id.empty?
      api.compute.show_server_details(id).map_to(Compute::Server)
    end

    def vnc_console(server_id,console_type='novnc')
      debug "[compute-service][Server] -> vnc_console -> POST /action"
      api.compute.get_vnc_console_os_getvncconsole_action(
        server_id,
        "os-getVNCConsole" => {'type' => console_type }
      ).map_to(Compute::VncConsole)
    end
    
  end
end