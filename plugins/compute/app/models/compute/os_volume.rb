# frozen_string_literal: true

module Compute
  # Represents the Server Volume
  class OsVolume < Core::ServiceLayer::Model
    def attachment_by_server_id(server_id)
      attachments.find { |a| a["server_id"] == server_id }
    end

    def attachment_device(server_id)
      attachment = attachment_by_server_id(server_id)
      return attachment["device"] if attachment
      nil
    end
  end
end
