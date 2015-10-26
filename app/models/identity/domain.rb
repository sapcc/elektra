module Identity
  class Domain < OpenstackServiceProvider::BaseObject
    
    def friendly_id
      return nil if id.nil?
      return id if name.blank?

      friendly_id_entry = FriendlyIdEntry.where(class_name: 'Domain', key:id).first_or_create(name:name)
      friendly_id_entry.slug
    end 
  end
end