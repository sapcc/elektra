module DnsService
  class ZoneTransferRequest < Core::ServiceLayer::Model
    def accept(target_project_id=nil)
      begin
        params= {key: self.key, zone_transfer_request_id: self.id}
        params[:target_project_id] = target_project_id if target_project_id
        @driver.create_zone_transfer_accept(params)
      rescue => e
        raise e unless defined?(@driver.handle_api_errors?) and @driver.handle_api_errors?

        Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each{|message| self.errors.add(:api, message)}
        return false
      end
    end
  end
end
