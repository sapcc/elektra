module SharedFilesystemStorage
  class Share < Core::ServiceLayer::Model
    
    def attributes_for_update
      {
        "display_name"              => read("name"),
        "display_description"       => read("description")
      }.delete_if { |k, v| v.blank? }
    end
    
    
    # msp to driver create method
    def perform_driver_create(create_attributes)
      protocol  = create_attributes.delete("share_proto")
      size      = create_attributes.delete("size")
      
      @driver.create_share(protocol, size, create_attributes)
    end    
  end
end