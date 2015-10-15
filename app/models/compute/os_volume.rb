module Compute
  class OsVolume < OpenstackServiceProvider::BaseObject
    def attachment_by_server_id(server_id)
      attachments.find{|a|a["server_id"]==server_id}
    end
    
    def attachment_device(server_id)
      attachment = attachment_by_server_id(server_id)
      attachment["device"] if attachment
    end
  end
end