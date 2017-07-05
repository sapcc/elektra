module Compute
  class Flavor < Core::ServiceLayerNg::Model
    def to_s
      "#{self.name}, #{self.vcpus} VCPUs, #{self.disk}GB Disk, #{self.ram}MB Ram" 
    end    
    
    # FOG already maps this field to ephemeral. It is only a backup. 
    def ephemeral
      read("OS-FLV-EXT-DATA:ephemeral") || read("ephemeral")
    end
    
    # convert is_public to boolean.
    def is_public?
      result = read("os-flavor-access:is_public") 
      if result.nil?
        result = read("is_public")
      end
      result == "1" || result == true 
    end
    
    # overwrite (defined in model.rb)
    # The save method is defined in the superclass. 
    # This method is used for both create and for update. 
    # However Flavors API does not support update. Therefore we override save so that 
    # it simulates an update by deleting the old flavor first and then creating a new one with the same id.
    def save
      # execute before callback
      before_save

      success = self.valid?

      if success
        unless id.blank?
          # try to delete the "old" flavor
          begin 
            @driver.delete_flavor(id) 
          rescue Core::ServiceLayer::Errors::ApiError => api_error
            unless api_error.type=='NotFound'
              Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(api_error).each{|message| self.errors.add(:api, message)}
              return false
            end
          rescue => e
            Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each{|message| self.errors.add(:api, message)}
            return false
          end
        end
      
        # get new attributes
        new_attributes = attributes_for_update.with_indifferent_access
        # set old id as new if exists
        new_attributes['id'] = id unless id.blank?
        
        # create the new flavor. Caution: if this operation fails then it is just a delete.
        begin
          self.attributes= @driver.create_flavor(new_attributes)
          success = true
          
        rescue => e
          raise e unless defined?(@driver.handle_api_errors?) and @driver.handle_api_errors?
          Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each{|message| self.errors.add(:api, message)}
          success = false
        end
      end  

      return success & after_save
    end
    
    # this method is called by save. It allows us to map values passed to the API.
    # For example the is_public attribute is converted to string. 
    def attributes_for_update
      {
        "name"         => read("name"),
        "ram"          => read("ram"),
        "vcpus"        => read("vcpus"),
        "disk"         => read("disk"),
        "rxtx_factor"  => read("rxtx_factor"),
        "swap"         => read("swap"),
        "ephemeral"    => ephemeral,
        "is_public"    => is_public?.to_s
        }.delete_if { |k, v| v.blank? }
    end
    
    protected
    # deactivate perform_create method. Use save instead!
    def perform_create
      raise 'Do not use this method in flavor. Use save instead'
    end
  end
end