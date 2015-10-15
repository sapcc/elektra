module Openstack
  class AdminIdentityService < OpenstackServiceProvider::Service
    
    def get_driver(params)
      servce_user_driver = MonsoonOpenstackAuth.api_client(@region).connection_driver.connection
      OpenstackServiceProvider::FogDriver::Identity.new(servce_user_driver)
    end

    def create_user_sandbox(domain_id, user)
      begin
        name = "#{user.name}_sandbox"
        user_sandbox = @driver.projects(name: name, domain_id: domain_id).first

        unless user_sandbox
          # get root project (sandboxes)
          sandboxes = @driver.projects(name: 'sandboxes', domain_id: domain_id)
          return nil unless sandboxes or sandboxes.length==0

          # create sandbox for user
          user_sandbox = @driver.create_project(domain_id: domain_id, name: name, description: "#{user.full_name}'s sandbox", enabled: true, parent_id: sandboxes.first["id"])
          return nil unless user_sandbox
        end

        # get admin role
        #admin_role = @service_connection.roles.all(name:'admin').first
        admin_role = role('admin')
        
        user_sandbox = Identity::Project.new(@driver,user_sandbox)
        
        # assign admin role to user for sandbox
        @driver.grant_project_user_role(user_sandbox.id,user.id,admin_role.id)

        return user_sandbox
      rescue => e
        p e
        raise e
        return nil
      end
    end
  
  
    ######################### FIND LOCAL 
    def find_or_create_local_domain(friendly_id_or_key)
      Domain.find_by_friendly_id_or_key(friendly_id_or_key) or 
      create_local_domain(friendly_id_or_key)
    end
    
    def find_or_create_local_project(local_domain, friendly_id_or_key)
      Project.find_by_domain_fid_and_fid(local_domain.slug,friendly_id_or_key) or 
      create_local_project(friendly_id_or_key,local_domain.key)
    end
      
    def create_local_domain(domain_id)
      # load remote domain
      remote_domain = begin
        @driver.map_to(Identity::Domain).get_domain(domain_id)
        
      rescue
        @driver.map_to(Identity::Domain).domains(:name => domain_id).first
      end
      # create local domain
      Domain.find_or_create_by_remote_domain(remote_domain)
    end
    
    def create_local_project(project_id, domain_id=nil)
      remote_project = begin
        @driver.map_to(Identity::Project).get_project(project_id)
      rescue 
        if domain_id
          @driver.map_to(Identity::Project).projects(domain_id: domain_id, :name => project_id).first
        else
          nil
        end
      end
      Project.find_or_create_by_remote_project(remote_project)
    end
    ########################### END
        
    def new_user?(current_user)
      current_user.roles.empty? or @driver.user_projects(current_user.id).empty?
    end
    
    def set_user_default_project(current_user,project_id)
      # raise "set_user_default_project"
      # user = service_user.users.find_by_id(current_user.id)
      # user.default_project_id = project_id
      # user.save
      
      @driver.update_user(current_user.id, default_project_id: project_id)
    end
    
    def create_user_domain_role(current_user,role_name)
      return false if current_user.nil? or role_name.nil?
      member_role = @driver.map_to(Identity::Role).roles(name: role_name).first
      @driver.grant_domain_user_role(current_user.user_domain_id,current_user.id,member_role.id)
    end
    
    def validate_token(token)
      raise "validate_token"
      service_user.tokens.validate(token) rescue false
    end
    
    def roles
      @roles ||= @driver.map_to(Identity::Role).roles
    end

    def role(name)
      roles.select { |r| r.name==name }.first
    end

    def domain_find_by_key_or_name id
      begin
        @driver.map_to(Identity::Domain).get_domain(id)
      rescue
        @driver.map_to(Identity::Domain).domains(:name => id).first
      end
    end
  end
end