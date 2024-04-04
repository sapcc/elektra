# frozen_string_literal: true

module ServiceLayer
  module ComputeServices
    # This module implements Openstack Domain API
    module Volume
      def volume_map
        @volume_map ||= class_map_proc(Compute::OsVolume)
      end

      def volumes(server, _filter = {})

      return [] if server.nil? || server.id.nil?
        if server.attributes.nil? || server.attributes.empty?
          # server is not loaded yet
          # load the server
          server = service_manager.compute.find_server!(server.id)
        end
        return [] if server&.attributes.nil? || !server.attributes["os-extended-volumes:volumes_attached"].kind_of?(Array)

        volume_ids = server.attributes["os-extended-volumes:volumes_attached"].map{ |v| v["id"] }
        volume_ids.map do |volume_id|
          service_manager.block_storage.find_volume(volume_id)
        end
      rescue Elektron::Errors::ApiResponse
        []
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
