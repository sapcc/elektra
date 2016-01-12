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
  end
end