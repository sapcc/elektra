module Identity
  class Project < ::DomainModelServiceLayer::Model
    validates :name, presence: {message: 'Name should not be empty'}
    validates :description, presence: {message: 'Please enter a description'}

    attr_accessor :inquiry_id # to close inquiry after creation
    
    def subprojects
      return @subprojetcs if @subprojetcs
      
      @subprojects = read(:subtree)
      if @subprojects.is_a?(Array)
        @subprojects = @subprojects.collect{|project_attrs| self.class.new(self.driver,project_attrs["project"])} 
      end
      @subprojects
    end
        
      
    def friendly_id
      return nil if id.nil?
      return id if domain_id.blank? or name.blank?

      friendly_id_entry = FriendlyIdEntry.find_or_create_entry('Project',domain_id,id,name)
      friendly_id_entry.slug
    end
    
    # def subprojects(available_projects=nil)
    #   return @sub_projects if @sub_projects
    #
    #   subtree = read(:subtree)
    #   @sub_projects = if subtree.is_a?(Array)
    #     subtree.collect{|project_attrs| self.class.new(self.driver,project_attrs["project"])}
    #   elsif subtree.is_a?(Hash)
    #     if available_projects
    #       available_projects = available_projects.inject({}){|hash,project| hash[project.id] = project; hash} if available_projects.is_a?(Array)
    #       convert_subtree_to_projects( subtree, available_projects)
    #     else
    #       subtree
    #     end
    #   else
    #     nil
    #   end
    # end
    
    # private
    # def convert_subtree_to_projects(hash,available_projects)
    #   projects = []
    #
    #   hash.each do |k,v|
    #     if v.is_a?(Hash)
    #       projects << { project: available_projects[k], subprojects: convert_subtree_to_projects(v,available_projects) }
    #     else
    #       projects << { project:  available_projects[k], subprojects: nil }
    #     end
    #   end
    #   projects
    # end
  end
end