# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module Server

      def new_server(params={})
        # this is used for inital create server dialog
        debug "[compute-service][Server] -> new_server"
        map_to(Compute::Server, params)
      end

      def servers(filter={}, _use_cache = false)
        api.compute.list_servers_detailed(filter).map_to(Compute::Server)
      end

      def create_server(params = {})
        api.compute.create_server(server: params).data
      end

      def delete_server(id)
        debug "[compute-service][Server] -> delete_server -> DELETE /servers/#{id}"
        return nil if id.empty?
        api.compute.delete_server(id)
      end

      def find_server!(id)
        debug "[compute-service][Server] -> find_server -> GET /servers/#{id}"
        return nil if id.empty?
        api.compute.show_server_details(id).map_to(Compute::Server)
      end

      def find_server(id)
        find_server!(id)
      rescue
        nil
      end

      def vnc_console(server_id,console_type='novnc')
        debug "[compute-service][Server] -> vnc_console -> POST /action"
        api.compute.get_vnc_console_os_getvncconsole_action_deprecated(
          server_id,
          "os-getVNCConsole" => {'type' => console_type }
        ).map_to(Compute::VncConsole)

        # TODO: since 2.5 remote-console should be available but for some reason it is not working
        #       got a 404 not available
        #api.compute.create_remote_console(
        #  id,
        #  "remote_console" => {
        #    'protocol'=>'vnc',
        #    'type' => console_type
        #}
      end

      def rebuild_server(server_id, image_ref, name, admin_pass=nil, metadata=nil, personality=nil)
        debug "[compute-service][Server] -> rebuild_server -> POST /action"

        # prepare data
        data = {'rebuild' => {
          'imageRef' => image_ref,
          'name'     => name
        }}
        data['rebuild']['adminPass'] = admin_pass if admin_pass
        data['rebuild']['metadata'] = metadata if metadata
        if personality
          body['rebuild']['personality'] = []
          personality.each do |file|
            data['rebuild']['personality'] << {
              'contents' => Base64.encode64(file['contents']),
              'path'     => file['path']
            }
          end
        end

        api.compute.rebuild_server_rebuild_action(server_id, data)
      end

      def resize_server(server_id, flavor_ref)
        debug "[compute-service][Server] -> resize_server -> POST /servers/#{server_id}/action"
        api.compute.resize_server_resize_action(server_id, 'resize' => {'flavorRef' => flavor_ref})
      end

      def confirm_resize_server(server_id)
        debug "[compute-service][Server] -> confirm_resize_server -> POST /servers/#{server_id}/action"
        api.compute.confirm_resized_server_confirmresize_action(server_id, 'confirmResize' => nil)
      end

      def revert_resize_server(server_id)
        debug "[compute-service][Server] -> revert_resize_server -> POST /servers/#{server_id}/action"
        api.compute.revert_resized_server_revertresize_action(server_id, 'revertResize' => nil)
      end

      def start_server(server_id)
        debug "[compute-service][Server] -> start_server -> POST /servers/#{server_id}/action"
        api.compute.start_server_os_start_action(server_id, 'os-start' => nil)
      end

      def stop_server(server_id)
        debug "[compute-service][Server] -> stop_server -> POST /servers/#{server_id}/action"
         api.compute.stop_server_os_stop_action(server_id, 'os-stop' => nil)
      end

      def reboot_server(server_id, type)
        debug "[compute-service][Server] -> reboot_server ->  /servers/#{server_id}/action"
        api.compute.reboot_server_reboot_action(
          server_id,
          'reboot' => {'type' => type}
        )
      end

      def suspend_server(server_id)
        debug "[compute-service][Server] -> suspend_server -> POST /servers/#{server_id}/action"
        api.compute.suspend_server_suspend_action(server_id, 'suspend' => nil)
      end

      def pause_server(server_id)
        debug "[compute-service][Server] -> pause_server -> POST /servers/#{server_id}/action"
        api.compute.pause_server_pause_action(server_id, 'pause' => nil)
      end

      def unpause_server(server_id)
        debug "[compute-service][Server] -> unpause_server -> POST /action"
        api.compute.unpause_server_unpause_action(server_id, 'unpause' => nil)
      end

      def reset_server_state(server_id, state)
        debug "[compute-service][Server] -> reset_server_state -> POST /servers/#{server_id}/action"
        api.compute.reset_server_state_os_resetstate_action(server_id, 'os-resetState' => {'state' => state})
      end

      def rescue_server(server_id)
        debug "[compute-service][Server] -> rescue_server -> POST /servers/#{server_id}/action"
        api.compute.rescue_server_rescue_action(server_id, 'rescue' => nil)
      end

      def resume_server(server_id)
        debug "[compute-service][Server] -> resume_server -> POST /servers/#{server_id}/action"
        api.compute.resume_suspended_server_resume_action(server_id, 'resume' => nil)
      end
    end
  end
end
