module DnsService
  class ZoneTransferRequest < Core::ServiceLayer::Model
    def accept
      begin
        @driver.create_zone_transfer_accept(key: self.key, zone_transfer_request_id: self.id)
      rescue => e
        raise e unless defined?(@driver.handle_api_errors?) and @driver.handle_api_errors?

        Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each{|message| self.errors.add(:api, message)}
        return false
      end  
    end
  end
end
