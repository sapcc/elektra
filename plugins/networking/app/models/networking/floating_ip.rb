module Networking
  class FloatingIp < Core::ServiceLayer::Model

    def attributes_for_create
      {
        "floating_network_id"              => read("floating_network_id"),
        "subnet_id"                        => read("floating_subnet_id")
      }.delete_if { |k, v| v.blank? }
    end

    def attach(port_id, options = {})
      begin
        # @driver.create_zone_transfer_accept(key: self.key, zone_transfer_request_id: self.id)
        @driver.associate_floating_ip(self.ip_id,port_id,options)
      rescue => e
        raise e unless defined?(@driver.handle_api_errors?) and @driver.handle_api_errors?

        Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each{|message| self.errors.add(:api, message)}
        return false
      end
      true
    end

  end
end
