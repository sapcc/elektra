# frozen_string_literal: true

module DnsService
  # represents the zone transfer request
  class ZoneTransferRequest < Core::ServiceLayer::Model
    # this method creates a request accept
    def accept(target_project_id = nil)
      rescue_api_errors do
        attrs = { key: key, zone_transfer_request_id: id }
        attrs[:target_project_id] = target_project_id if target_project_id
        service.create_zone_transfer_accept(attrs)
      end
    end

    def perform_service_create(create_attributes)
      service.create_zone_transfer_request(zone_id, create_attributes)
    end
  end
end
