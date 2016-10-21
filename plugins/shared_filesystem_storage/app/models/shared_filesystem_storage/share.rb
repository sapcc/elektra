module SharedFilesystemStorage
  class Share < Core::ServiceLayer::Model
    
    
    # msp to driver create method
    def perform_driver_create(create_attributes)
      protocol  = create_attributes.delete("share_proto")
      size      = create_attributes.delete("size")
      
      @driver.create_share(protocol, size, create_attributes)
    end    
  end
end