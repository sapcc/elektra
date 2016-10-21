module SharedFilesystemStorage
  class Snapshot < Core::ServiceLayer::Model
    
    
    # msp to driver create method
    def perform_driver_create(create_attributes)
      share_id  = create_attributes.delete("share_id")
      @driver.create_snapshot(share_id, create_attributes)
    end    
  end
end