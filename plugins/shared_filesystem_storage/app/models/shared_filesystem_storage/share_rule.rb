# frozen_string_literal: true

module SharedFilesystemStorage
  # represents access rule
  class ShareRule < Core::ServiceLayer::Model
    # msp to driver create method
    def perform_service_create(create_attributes)
      share_id = create_attributes.delete("share_id")
      service.create_share_rule(share_id, create_attributes)
    end

    def perform_service_delete(id)
      service.delete_share_rule(share_id, id)
    end
  end
end
