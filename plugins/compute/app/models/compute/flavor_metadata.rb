module Compute
  class FlavorMetadata < Core::ServiceLayerNg::Model
    def save
      raise "Do not use save. Use add and remove instead"
    end
    
    def destroy
      raise "Do not use destroy. Use add and remove instead" 
    end
    
    def update
      raise "Do not use update!"
    end
    
    def add(params)
      begin
        attrs = @driver.create_flavor_metadata(self.flavor_id, { params[:key] => params[:value]})
        self.attributes=attrs if attrs
      rescue => e
        raise e unless defined?(@driver.handle_api_errors?) and @driver.handle_api_errors?
        Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each{|message| self.errors.add(:api, message)}
        success = false
      end
    end
    
    def remove(key)
      begin
        @driver.delete_flavor_matadata(self.flavor_id, key)
        return true
      rescue => e
        raise e unless defined?(@driver.handle_api_errors?) and @driver.handle_api_errors?
        Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each{|message| self.errors.add(:api, message)}
        success = false
      end
    end
  end
end