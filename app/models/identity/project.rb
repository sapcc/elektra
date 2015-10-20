module Identity
  class Project < OpenstackServiceProvider::BaseObject
    def is_sandbox?
      self.name.end_with? "_sandbox"
    end
    
    # def friendly_id
    #   return nil if id.nil?
    #   return id if domain_id.blank? or name.blank?
    #
    #   friendly_id_entry = FriendlyIdCache.find_or_create_entry(self.class.name,domain_id,id,name)
    #   friendly_id_entry.slug
    # end
    
    def friendly_id
      project = ::Project.find_or_create_by_remote_project(self)
      project.nil? ? self.id : project.slug
    end
  end
end