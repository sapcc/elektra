module Identity
  class Project < OpenstackServiceProvider::BaseObject
    def is_sandbox?
      self.name.end_with? "_sandbox"
    end
    
    def friendly_id
      project = ::Project.find_or_create_by_remote_project(self)
      project.nil? ? self.id : project.slug
    end
  end
end