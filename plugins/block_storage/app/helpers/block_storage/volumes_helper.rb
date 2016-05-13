module BlockStorage
  module VolumesHelper

    def get_attachments volume, servers
      attachments = []
      if volume.status == "in-use"
        volume.attachments.each do |att|
          unless servers
            servers = services.compute.servers()
          end
          serverId = att['server_id'] || att['serverId']
          server = servers.select { |s| s.id == serverId }
          attachments << {device: att['device'], server_id: serverId, server_name: server.first.name}
        end
      end
      return attachments
    end
  end
end
