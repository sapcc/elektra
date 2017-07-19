# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module Server
      def new_server(params = {})
        # this is used for inital create server dialog
        map_to(Compute::Server, params)
      end

      def servers(filter = {})
        api.compute.list_servers_detailed(filter)
           .map_to('servers' => Compute::Server) || []
      end

      def cached_project_servers(project_id)
        data = Rails.cache.fetch("#{project_id}_servers",
                                 expires_in: 2.hours) do
          api.compute.list_servers_detailed.data
        end
        map_to(Compute::Server, data)
      end

      def find_server!(id)
        return nil if id.empty?
        api.compute.show_server_details(id).map_to(Compute::Server)
      end

      def find_server(id)
        find_server!(id)
      rescue
        nil
      end

      def vnc_console(server_id, console_type = 'novnc')
        api.compute.get_vnc_console_os_getvncconsole_action_deprecated(
          server_id,
          'os-getVNCConsole' => { 'type' => console_type }
        ).map_to(Compute::VncConsole)

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

      def rebuild_server(server_id, image_ref, name, admin_pass=nil, metadata=nil, personality=nil)
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

        api.compute.rebuild_server_rebuild_action(server_id, 'rebuild' => data)
      end

      def resize_server(server_id, flavor_ref)
        api.compute.resize_server_resize_action(
          server_id, 'resize' => { 'flavorRef' => flavor_ref }
        )
      end

      def confirm_resize_server(server_id)
        api.compute.confirm_resized_server_confirmresize_action(
          server_id, 'confirmResize' => nil
        )
      end

      def revert_resize_server(server_id)
        api.compute.revert_resized_server_revertresize_action(
          server_id, 'revertResize' => nil
        )
      end

      def start_server(server_id)
        api.compute.start_server_os_start_action(server_id, 'os-start' => nil)
      end

      def stop_server(server_id)
        api.compute.stop_server_os_stop_action(server_id, 'os-stop' => nil)
      end

      def reboot_server(server_id, type)
        api.compute.reboot_server_reboot_action(
          server_id,
          'reboot' => { 'type' => type }
        )
      end

      def suspend_server(server_id)
        api.compute.suspend_server_suspend_action(server_id, 'suspend' => nil)
      end

      def pause_server(server_id)
        api.compute.pause_server_pause_action(server_id, 'pause' => nil)
      end

      def unpause_server(server_id)
        api.compute.unpause_server_unpause_action(server_id, 'unpause' => nil)
      end

      def reset_server_state(server_id, state)
        api.compute.reset_server_state_os_resetstate_action(
          server_id, 'os-resetState' => { 'state' => state }
        )
      end

      def rescue_server(server_id)
        api.compute.rescue_server_rescue_action(server_id, 'rescue' => nil)
      end

      def resume_server(server_id)
        api.compute.resume_suspended_server_resume_action(
          server_id, 'resume' => nil
        )
      end

      ################## MODEL INTERFACE ######################
      def create_server(params = {})
        api.compute.create_server(server: params).data
      end

      def delete_server(id)
        return nil if id.empty?
        api.compute.delete_server(id)
      end
    end
  end
end
