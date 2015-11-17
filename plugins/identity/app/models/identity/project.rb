module Identity
  class Project < ::DomainModelServiceLayer::Model
    def is_sandbox?
      self.name.end_with? "_sandbox"
    end
    
    def subtree
      unless @sub_projects 
        @sub_projects = []
        projects = read(:subtree)
        if projects 
          @sub_projects = projects.collect{|project_attrs| Identity::Project.new(self.driver,project_attrs["project"])}
        end 
      end
      @sub_projects
    end
  
    def friendly_id
      return nil if id.nil?
      return id if domain_id.blank? or name.blank?

      friendly_id_entry = FriendlyIdEntry.where(class_name: 'Project', scope: domain_id, key:id).first_or_create(name:name)
      friendly_id_entry.slug
    end
  end
end