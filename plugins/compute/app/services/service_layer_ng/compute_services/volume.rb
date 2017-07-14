# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module Volume

      def attach_volume(volume_id, server_id, device)
        debug "[compute-service][Volume] -> attach_volume #{volume_id} -> POST /action"
        api.compute.attach_a_volume_to_an_instance(
          server_id,
          'volumeAttachment' => {
          'volumeId' => volume_id.to_s,
          'device'   => device
        })
      end

      def detach_volume(volume_id, server_id)
        debug "[compute-service][Volume] -> detach_volume #{volume_id} -> DELETE /action"
        api.compute.detach_a_volume_from_an_instance(server_id,volume_id)
      end

      def volumes(server_id,filter={})
        debug "[compute-service][Volume] -> volumes -> GET /os-volumes"
        response = api.compute.list_volumes(filter)
        response.body['volumes'].select{|vol|
          vol["attachments"].find { |attachment| attachment["serverId"] == server_id or attachment["server_id"] == server_id}
        }.collect{|v| map_to(Compute::OsVolume,v)}
      end
    end
  end
end
