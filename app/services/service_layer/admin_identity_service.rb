module ServiceLayer
  class AdminIdentityService < DomainModelServiceLayer::Service
  
    def driver
      unless @driver
        servce_user_connection = MonsoonOpenstackAuth.api_client(@region).connection_driver.connection
        @driver = Identity::Driver::Fog.new(servce_user_connection)
      end
      @driver
    end

    def create_user_sandbox(domain_id, user)
      begin
        name = "#{user.name}_sandbox"
        user_sandbox = driver.projects(name: name, domain_id: domain_id).first

        unless user_sandbox
          # get root project (sandboxes)
          sandboxes = driver.projects(name: 'sandboxes', domain_id: domain_id)
          return nil unless sandboxes or sandboxes.length==0

          # create sandbox for user
          user_sandbox = driver.create_project(domain_id: domain_id, name: name, description: "#{user.full_name}'s sandbox", enabled: true, parent_id: sandboxes.first["id"])
          return nil unless user_sandbox
        end

        # get admin role
        #admin_role = @service_connection.roles.all(name:'admin').first
        admin_role = role('admin')
           
        # assign admin role to user for sandbox
        driver.grant_project_user_role(user_sandbox["id"],user.id,admin_role["id"])

        return user_sandbox["id"]
      rescue => e
        p e
        raise e
        return nil
      end
    end

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
        domain_attrs = begin 
          driver.get_domain(domain_fid_id_or_key)
        rescue
          # assume domain_fid_id_or_key is domain name  
          driver.domains(:name => domain_fid_id_or_key).first
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
          driver.get_project(project_fid_or_key)
        rescue
          if domain_id
            driver.projects(domain_id: domain_id, :name => project_fid_or_key).first rescue nil
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
    ##########################################################################

    def new_user?(current_user)
      current_user.roles.empty? and driver.user_projects(current_user.id).empty?
    end
  
    def set_user_default_project(current_user,project_id)
      # raise "set_user_default_project"
      # user = service_user.users.find_by_id(current_user.id)
      # user.default_project_id = project_id
      # user.save
    
      driver.update_user(current_user.id, default_project_id: project_id)
    end
  
    def create_user_domain_role(current_user,role_name)
      return false if current_user.nil? or role_name.nil?
      member_role = role(role_name)
      driver.grant_domain_user_role(current_user.user_domain_id,current_user.id,member_role["id"])
    end
  
    def validate_token(token)
      driver.validate(token) rescue false
    end
  
    def roles
      @roles ||= driver.roles
    end

    def role(name)
      roles.select { |r| r["name"]==name }.first
    end

    def domain id_or_name
      begin
        driver.get_domain(id_or_name)
      rescue
        driver.domains(:name => id_or_name).first rescue nil
      end
    end
  end
end
