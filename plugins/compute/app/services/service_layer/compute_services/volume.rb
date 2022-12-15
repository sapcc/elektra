# frozen_string_literal: true

module ServiceLayer
  module ComputeServices
    # This module implements Openstack Domain API
    module Volume
      def volume_map
        @volume_map ||= class_map_proc(Compute::OsVolume)
      end

      # DEPRECATED: please use the volumes method from block_storage plugin!
      def volumes(server_id, _filter = {})
        # volumes = elektron_compute.get('os-volumes', filter).body['volumes']
        volumes = service_manager.block_storage.volumes_detail

        server_volumes =
          volumes.select do |vol|
            vol.attachments.find do |attachment|
              attachment["serverId"] == server_id ||
                attachment["server_id"] == server_id
            end
          end
      end

      def attach_volume(volume_id, server_id, device)
        elektron_compute.post("servers/#{server_id}/os-volume_attachments") do
          {
            "volumeAttachment" => {
              "volumeId" => volume_id.to_s,
              "device" => device,
            },
          }
        end
      end

      def detach_volume(volume_id, server_id)
        elektron_compute.delete(
          "servers/#{server_id}/os-volume_attachments/#{volume_id}",
        )
      end
    end
  end
end
