module SharedFilesystemStorage
  class ShareRule < Core::ServiceLayer::Model
    
    # msp to driver create method
    def perform_driver_create(create_attributes)
      share_id  = create_attributes.delete("share_id")
      
      p "::::::::::::::::::::::::::::"
      p "share_id: #{share_id}"
      p "create_attributes"
      puts create_attributes
      @driver.grant_share_access(share_id, create_attributes)
    end    
    
    def perform_driver_delete(id)
      @driver.revoke_share_access(share_id, id)
    end
  end
end