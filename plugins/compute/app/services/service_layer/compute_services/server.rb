# frozen_string_literal: true

module ServiceLayer
  module ComputeServices
    # This module implements Openstack Domain API
    module Server
      def server_map
        @server_map ||= class_map_proc(Compute::Server)
      end

      def new_server(attributes = {})
        # this is used for inital create server dialog
        server_map.call(attributes)
      end

      def servers(filter = {})
        elektron_compute.get('servers/detail', filter).map_to(
          'body.servers', &server_map
        ) || []
      end

      def cached_project_servers(project_id)
        data = Rails.cache.fetch("#{project_id}_servers",
                                 expires_in: 2.hours) do
          elektron_compute.get('servers/detail').body['servers']
        end
        data.collect { |params| server_map.call(params) }
      end

      def find_server!(id)
        return nil if id.empty?
        elektron_compute.get("servers/#{id}").map_to('body.server', &server_map)
      end

      def find_server(id)
        find_server!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def vnc_console(server_id, console_type = 'novnc')
        response = elektron_compute.post("servers/#{server_id}/action") do
          { 'os-getVNCConsole': { 'type': console_type } }
        end

        response.map_to('body.console') do |data|
          Compute::VncConsole.new(self, data)
        end

        # TODO: since 2.5 remote-console should be available but for
        # some reason it is not working
        #       got a 404 not available
        # api.compute.create_remote_console(
        #  id,
        #  "remote_console" => {
        #    'protocol'=>'vnc',
        #    'type' => console_type
        # }
      end

      def shellinabox_console(server_id, console_type = 'shellinabox')
        response = elektron_compute.post("servers/#{server_id}/action") do
          { 'os-getSerialConsole': { 'type': console_type } }
        end

        response.map_to('body.console') do |data|
          Compute::ShellinaboxConsole.new(self, data)
        end
      end

      def rebuild_server(server_id, image_ref, name, admin_pass = nil,
                         metadata = nil, personality = nil)
        # prepare data
        data = {
          'imageRef' => image_ref,
          'name'     => name
        }
        data['adminPass'] = admin_pass if admin_pass
        data['metadata'] = metadata if metadata

        if personality
          data['personality'] = personality.collect do |file|
            data['personality'] << {
              'contents' => Base64.encode64(file['contents']),
              'path'     => file['path']
            }
          end
        end

        elektron_compute.post("servers/#{server_id}/action") do
          { 'rebuild' => data }
        end
      end

      def resize_server(server_id, flavor_ref)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'resize' => { 'flavorRef' => flavor_ref } }
        end
      end

      def confirm_resize_server(server_id)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'confirmResize' => nil }
        end
      end

      def revert_resize_server(server_id)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'revertResize' => nil }
        end
      end

      def start_server(server_id)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'os-start' => nil }
        end
      end

      def stop_server(server_id)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'os-stop' => nil }
        end
      end

      def reboot_server(server_id, type)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'reboot' => { 'type' => type } }
        end
      end

      def suspend_server(server_id)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'suspend' => nil }
        end
      end

      def pause_server(server_id)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'pause' => nil }
        end
      end

      def unpause_server(server_id)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'unpause' => nil }
        end
      end

      def reset_server_state(server_id, state)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'os-resetState' => { 'state' => state } }
        end
      end

      def rescue_server(server_id)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'rescue' => nil }
        end
      end

      def resume_server(server_id)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'resume' => nil }
        end
      end

      def lock_server(server_id)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'lock' => nil }
        end
      end

      def unlock_server(server_id)
        elektron_compute.post("servers/#{server_id}/action") do
          { 'unlock' => nil }
        end
      end

      ################## MODEL INTERFACE ######################
      def update_metadata_key(server_id, key, value)
        elektron_compute.put("/servers/#{server_id}/metadata/#{key}") do
          { 'meta' => { key => value } }
        end
      end

      def create_server(params = {})
        elektron_compute.post('servers') do
          { server: params }
        end.body['server']
      end

      def update_server(id, params = {})
        elektron_compute.put("servers/#{id}") do
          { server: params }
        end.body['server']
      end

      def delete_server(id)
        return nil if id.empty?
        elektron_compute.delete("servers/#{id}")
      end
    end
  end
end
