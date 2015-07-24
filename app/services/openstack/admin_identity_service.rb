module Openstack
  class AdminIdentityService < OpenstackServiceProvider::BaseProvider

    def create_user_sandbox(domain_id, user)
      begin
        name = "#{user.name}_sandbox"
        user_sandbox = service_user.projects.all(name: name, domain_id: domain_id).first

        unless user_sandbox
          # get root project (sandboxes)
          sandboxes = service_user.projects.all(name: 'sandboxes', domain_id: domain_id)
          return nil unless sandboxes or sandboxes.length==0

          # create sandbox for user
          user_sandbox = sandboxes.create(domain_id: domain_id, name: name, description: "#{user.full_name}'s sandbox", enabled: true, parent_id: sandboxes.first.id)
          return nil unless user_sandbox
        end

        # get admin role
        #admin_role = @service_connection.roles.all(name:'admin').first
        admin_role = role('admin')
        # assign admin role to user for sandbox
        user_sandbox.grant_role_to_user(admin_role.id, user.id)

        return user_sandbox
      rescue => e
        p e
        return nil
      end
    end
    
    def new_user?(user_id)
      user = service_user.users.find_by_id(user_id)
      user.roles.length==0 or user.projects.count==0
    end
    
    def set_user_default_project(current_user,project_id)
      user = service_user.users.find_by_id(current_user.id)
      user.default_project_id = project_id
      user.save
    end
    
    def create_user_domain_role(user_id,role_name)
      return false if user_id.nil? or role_name.nil?
      user = service_user.users.find_by_id(user_id)
      member_role = service_user.roles.all(name:role_name).first
      user.grant_role(member_role.id)
    end
    
    def validate_token(token)
      service_user.tokens.validate(token) rescue false
    end
    
    def roles
      @roles ||= service_user.roles
    end

    def role(name)
      roles.select { |r| r.name==name }.first
    end

    def domain_find_by_key_or_name id
      begin
        service_user.domains.find_by_id id
      rescue
        service_user.domains.all(:name => id).first
      end
    end

    def project_find_by_key_or_name id
      begin
        service_user.projects.find_by_id id
      rescue
        service_user.projects.all(:name => id).first
      end
    end

    def service_user
      @service_user ||= MonsoonOpenstackAuth.api_client(@region).connection_driver.connection
    end
  end
end