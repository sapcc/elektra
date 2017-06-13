module SharedFilesystemStorage
  class ShareNetwork < Core::ServiceLayer::Model
    def attributes_for_update
      {
        "name"              => read("name"),
        "description"       => read("description")
      }.delete_if { |k, v| v.blank? }
    end

    def add_security_service(security_service_id)
      requires :id
      rescue_errors do
        @driver.add_security_service_to_share_network(security_service_id,self.id)
      end
    end

    def remove_security_service(security_service_id)
      requires :id
      rescue_errors do
        @driver.remove_security_service_from_share_network(security_service_id,self.id)
      end
    end
  end
end
