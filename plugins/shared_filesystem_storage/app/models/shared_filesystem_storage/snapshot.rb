module SharedFilesystemStorage
  class Snapshot < Core::ServiceLayer::Model
    
    def attributes_for_update
      {
        "display_name"              => read("name"),
        "display_description"       => read("description")
      }.delete_if { |k, v| v.blank? }
    end
    
    # msp to driver create method
    def perform_driver_create(create_attributes)
      share_id  = create_attributes.delete("share_id")
      @driver.create_snapshot(share_id, create_attributes)
    end    
  end
end