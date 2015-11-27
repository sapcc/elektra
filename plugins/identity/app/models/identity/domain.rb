module Identity
  class Domain < DomainModelServiceLayer::Model
    
    def friendly_id
      return nil if id.nil?
      return id if name.blank?

      friendly_id_entry = FriendlyIdEntry.find_or_create_entry('Domain',nil,id,name)
      friendly_id_entry.slug
    end 
  end
end