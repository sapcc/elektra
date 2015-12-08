module Identity
  class Project < ::DomainModelServiceLayer::Model
    validates :name, presence: {message: 'Name should not be empty'}

    attr_accessor :inquiry_id # to close inquiry after creation
    
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

      friendly_id_entry = FriendlyIdEntry.find_or_create_entry('Project',domain_id,id,name)
      friendly_id_entry.slug
    end
  end
end