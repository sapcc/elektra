# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module Volume
      def volume_map
        @volume_map ||= class_map_proc(Compute::OsVolume)
      end

      def volumes(server_id, filter = {})
        # volumes = api.compute.list_volumes(filter).body['volumes']
        volumes = elektron_compute.get('os-volumes', filter).body['volumes']

        server_volumes = volumes.select do |vol|
          vol['attachments'].find do |attachment|
            attachment['serverId'] == server_id ||
              attachment['server_id'] == server_id
          end
        end

        server_volumes.collect { |data| volume_map.call(data) }
      end

      def attach_volume(volume_id, server_id, device)
        elektron_compute.post("servers/#{server_id}/os-volume_attachments") do
          {
            'volumeAttachment' => {
              'volumeId' => volume_id.to_s,
              'device' => device
            }
          }
        end
      end

      def detach_volume(volume_id, server_id)
        elektron_compute.delete(
          "servers/#{server_id}/os-volume_attachments/#{volume_id}"
        )
      end
    end
  end
end
