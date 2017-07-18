# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module Volume
      def attach_volume(volume_id, server_id, device)
        api.compute.attach_a_volume_to_an_instance(
          server_id,
          'volumeAttachment' => {
            'volumeId' => volume_id.to_s, 'device' => device
          }
        )
      end

      def detach_volume(volume_id, server_id)
        api.compute.detach_a_volume_from_an_instance(server_id, volume_id)
      end

      def volumes(server_id, filter = {})
        volumes = api.compute.list_volumes(filter).body['volumes']
        server_volumes = volumes.select do |vol|
          vol['attachments'].find do |attachment|
            attachment['serverId'] == server_id ||
              attachment['server_id'] == server_id
          end
        end
        map_to(Compute::OsVolume, server_volumes)
      end
    end
  end
end
