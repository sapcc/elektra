module SharedFilesystemStorage
  class SecurityService < Core::ServiceLayer::Model

    def attributes_for_update
      attrs = if self.status=='active'
        {
          "name"              => read("name"),
          "description"       => read("description")
        }
      else
        {
          "type"        => read("type"),
          "name"        => read("name"),
          "dns_ip"      => read("dns_ip"),
          "description" => read("description"),
          "user"        => read("user"),
          "password"    => read("password"),
          "domain"      => read("domain"),
          "server"      => read("server")
        }
      end
      attrs.delete_if { |k, v| v.blank? }
    end


    # msp to driver create method
    def perform_driver_create(create_attributes)
      type  = create_attributes.delete("type")
      name  = create_attributes.delete("name")

      @driver.create_security_service(type, name, create_attributes)
    end
  end
end
