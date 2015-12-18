module Admin  
  class RescopingService
    
    class << self
    
      ########################## FRIENDLY_ID_ENTRIES #########################
      # find or create friendly_id entry for domain
      def domain_friendly_id(domain_fid_id_or_key)
        # try to find an entry by given fid or key
        entry = FriendlyIdEntry.find_by_class_scope_and_key_or_slug('Domain',nil,domain_fid_id_or_key)
        # no entry found -> create a new one
        unless entry
          # assume domain_fid_id_or_key is domain id
          domain = begin 
            Admin::IdentityService.find_domain(domain_fid_id_or_key)
          rescue => e
            # assume domain_fid_id_or_key is domain name  
            Admin::IdentityService.domains(:name => domain_fid_id_or_key).first
          end

          # create friendly_id entry
          if domain
            entry = FriendlyIdEntry.find_or_create_entry('Domain', nil, domain.id, domain.name)
          end
        end
        entry
      end
  
      # find or create friendly_id entry for project
      def project_friendly_id(domain_id, project_fid_or_key)
        # try to find an entry by given fid or key
        entry = FriendlyIdEntry.find_by_class_scope_and_key_or_slug('Project',domain_id,project_fid_or_key)
    
        # no entry found -> create a new one
        unless entry
          project = begin
            #driver.get_project(project_fid_or_key)
            Admin::IdentityService.find_project(project_fid_or_key)
          rescue
            if domain_id
              #driver.projects(domain_id: domain_id, :name => project_fid_or_key).first rescue nil
              Admin::IdentityService.projects(domain_id: domain_id, :name => project_fid_or_key).first rescue nil  
            else
              nil
            end
          end
        end
    
        # create friendly_id entry
        if project
          entry = FriendlyIdEntry.find_or_create_entry('Project', project.domain_id, project.id, project.name)
        end
        entry
      end  
    end
  end
end