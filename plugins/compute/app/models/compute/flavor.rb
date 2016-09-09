module Compute
  class Flavor < Core::ServiceLayer::Model
    def to_s
      "#{self.name}, #{self.vcpus} VCPUs, #{self.disk}GB Disk, #{self.ram}MB Ram" 
    end    
    
    def ephemeral
      read("OS-FLV-EXT-DATA:ephemeral") || read("ephemeral")
    end
    
    def is_public?
      result = read("os-flavor-access:is_public") 
      if result.nil?
        result = read("is_public")
      end
      result == "1" || result == true 
    end
    
    
    # overwrite (defined in model.rb)
    def save
      # execute before callback
      before_save

      success = self.valid?

      if success
        unless id.blank?
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
      
        new_attributes = attributes_for_update.with_indifferent_access
        new_attributes['id'] = id unless id.blank?
        
        begin
          @driver.create_flavor(new_attributes)
        rescue => e
          raise e unless defined?(@driver.handle_api_errors?) and @driver.handle_api_errors?
          Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each{|message| self.errors.add(:api, message)}
          success = false
        end
      end  

      return success & after_save
    end
    
    
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
    def perform_create
      raise 'Do not use this method in flavor.'
    end
  end
end