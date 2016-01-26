module Identity
  class Project < ::DomainModelServiceLayer::Model
    validates :name, presence: {message: 'Name should not be empty'}
    validates :description, presence: {message: 'Please enter a description'}

    attr_accessor :inquiry_id # to close inquiry after creation
    
    def subprojects_ids
      return @subprojetcs_ids if @subprojetcs_ids

      @subprojetcs_ids = read(:subtree)
      if @subprojetcs_ids.is_a?(Array)
        @subprojetcs_ids = @subprojetcs_ids.collect{|project_attrs| project_attrs.fetch("project",{}).fetch("id",nil)}
      end
      @subprojetcs_ids
    end
    
    def parents_project_ids
      return @parents_project_ids if @parents_project_ids
      @parents_project_ids = read(:parents)
      if @parents_project_ids.is_a?(Array)
        @parents_project_ids = @parents_project_ids.collect{|project_attrs| project_attrs.fetch("project",{}).fetch("id",nil)}
      elsif @parents_project_ids.is_a?(Hash)
        to_array = lambda do |hash,array=[]| 
          hash.each{|k,v| array << k; to_array[v,array]} if hash
          array
        end
        @parents_project_ids = to_array[@parents_project_ids]
      end
      @parents_project_ids
    end
                 
    def friendly_id
      return nil if id.nil?
      return id if domain_id.blank? or name.blank?

      friendly_id_entry = FriendlyIdEntry.find_or_create_entry('Project',domain_id,id,name)
      friendly_id_entry.slug
    end
    
  end
end