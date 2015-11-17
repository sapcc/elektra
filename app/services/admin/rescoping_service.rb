module Admin  
  class RescopingService
    
    class << self
    
      ########################## FRIENDLY_ID_ENTRIES #########################
      def reset_domain_friendly_id(domain_id)
        sql = ["class_name=? and (slug=? or key=?)",'Domain',domain_id,domain_id]
        entry = FriendlyIdEntry.where(sql).first
        entry.delete if entry
      end
  
      # find or create friendly_id entry for domain
      def domain_friendly_id(domain_fid_id_or_key)
        # try to find an entry by given fid or key
        entry = FriendlyIdEntry.find_by_class_scope_and_key_or_slug('Domain',nil,domain_fid_id_or_key)
        # no entry found -> create a new one
        unless entry
          # assume domain_fid_id_or_key is domain id
          domain = begin 
            #driver.get_domain(domain_fid_id_or_key)
            Admin::IdentityService.find_domain(domain_fid_id_or_key)
          rescue
            # assume domain_fid_id_or_key is domain name  
            #driver.domains(:name => domain_fid_id_or_key).first
            Admin::IdentityService.domains(:name => domain_fid_id_or_key).first
          end

          # create friendly_id entry
          if domain
            entry = FriendlyIdEntry.create(class_name: 'Domain', key: domain.id, name: domain.name)
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
          entry = FriendlyIdEntry.create(class_name: 'Project', scope: project.domain_id, key: project.id, name: project.name)
        end
        entry
      end  
    end
  end
end