class RescopingService
  def initialize
    @admin_identity = DomainModelServiceLayer::ServicesManager.service_as_admin(:identity)
  end
  
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
      domain_attrs = begin 
        @admin_identity.domain(domain_fid_id_or_key)
      rescue
        # assume domain_fid_id_or_key is domain name  
        @admin_identity.domains(:name => domain_fid_id_or_key).first
      end

      # create friendly_id entry
      if domain_attrs
        entry = FriendlyIdEntry.create(class_name: 'Domain', key: domain_attrs["id"], name: domain_attrs["name"])
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
      project_attrs = begin
        @admin_identity.project(project_fid_or_key)
      rescue
        if domain_id
          @admin_identity.projects(domain_id: domain_id, :name => project_fid_or_key).first rescue nil
        else
          nil
        end
      end
    end
  
    # create friendly_id entry
    if project_attrs
      entry = FriendlyIdEntry.create(class_name: 'Project', scope: project_attrs["domain_id"], key: project_attrs["id"], name: project_attrs["name"])
    end
    entry
  end
end