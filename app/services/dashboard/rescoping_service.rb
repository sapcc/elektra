module Dashboard  
  class RescopingService
    
    def initialize(service_user)
      @service_user = service_user  
    end
        
    ########################## FRIENDLY_ID_ENTRIES #########################
    # find or create friendly_id entry for domain
    def domain_friendly_id(domain_fid_id_or_key)
      # try to find an entry by given fid or key
      entry = FriendlyIdEntry.find_by_class_scope_and_key_or_slug('Domain',nil,domain_fid_id_or_key)
      # no entry found -> create a new one
      unless entry
        entry = FriendlyIdEntry.find_or_create_entry('Domain', nil, @service_user.domain_id, @service_user.domain_name) if @service_user
      end
      entry
    end

    # find or create friendly_id entry for project
    def project_friendly_id(domain_id, project_fid_or_key)
      # try to find an entry by given fid or key
      entry = FriendlyIdEntry.find_by_class_scope_and_key_or_slug('Project',domain_id,project_fid_or_key)
  
      # no entry found -> create a new one
      unless entry
        project = @service_user.find_project_by_name_or_id(project_fid_or_key) if @service_user
        # create friendly_id entry
        if project
          entry = FriendlyIdEntry.find_or_create_entry('Project', project.domain_id, project.id, project.name)
        end
      end
      entry
    end  
  end
end