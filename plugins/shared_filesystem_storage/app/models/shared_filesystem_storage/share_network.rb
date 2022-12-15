# frozen_string_literal: true

module SharedFilesystemStorage
  # represents share network
  class ShareNetwork < Core::ServiceLayer::Model
    def attributes_for_update
      {
        "name" => read("name"),
        "description" => read("description"),
      }.delete_if { |_k, v| v.blank? }
    end

    def add_security_service(security_service_id)
      requires :id
      rescue_api_errors do
        service.add_security_service_to_share_network(security_service_id, id)
      end
    end

    def remove_security_service(security_service_id)
      requires :id
      rescue_api_errors do
        service.remove_security_service_from_share_network(
          security_service_id,
          id,
        )
      end
    end
  end
end
