module BlockStorage
  module VolumesHelper
    def get_attachments(volume)
      attachments = []
      if volume.status == "in-use"
        volume.attachments.each do |att|
          server_id = att["server_id"] || att["serverId"]
          server = ::ObjectCache.where(id: server_id).first

          attachments << {
            device: att["device"],
            server_id: server_id,
            server_name: server ? server.name : server_id,
          }
        end
      end
      return attachments
    end
  end
end
