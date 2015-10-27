module Identity
  class Project < OpenstackServiceProvider::BaseObject
    def is_sandbox?
      self.name.end_with? "_sandbox"
    end
    
    def friendly_id
      return nil if id.nil?
      return id if domain_id.blank? or name.blank?

      friendly_id_entry = Core::FriendlyIdEntry.where(class_name: 'Project', scope: domain_id, key:id).first_or_create(name:name)
      friendly_id_entry.slug
    end
  end
end