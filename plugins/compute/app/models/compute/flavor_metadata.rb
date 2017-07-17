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
        attrs = @service.create_flavor_metadata(self.flavor_id, { params[:key] => params[:value]})
        self.attributes=attrs if attrs
      rescue => e
        raise e unless defined?(@service.handle_api_errors?) and @service.handle_api_errors?
        Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each{|message| self.errors.add(:api, message)}
        success = false
      end
    end
    
    def remove(key)
      begin
        @service.delete_flavor_metadata(self.flavor_id, key)
        return true
      rescue => e
        raise e unless defined?(@service.handle_api_errors?) and @service.handle_api_errors?
        Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each{|message| self.errors.add(:api, message)}
        success = false
      end
    end
  end
end