module Openstack
  class AdminIdentityService < OpenstackServiceProvider::BaseProvider
    
    def create_user_sandbox(domain_id,user)
      begin
        name = "#{user.name}_sandbox"
        user_sandbox = service_user.projects.all(name: name, domain_id: domain_id).first

        unless user_sandbox
          # get root project (sandboxes)
          sandboxes = service_user.projects.all(name:'sandboxes',domain_id: domain_id)
          return nil unless sandboxes or sandboxes.length==0

          # create sandbox for user
          user_sandbox = sandboxes.create(domain_id: domain_id, name: name, description: "#{user.full_name}'s sandbox", enabled: true, parent_id: sandboxes.first.id)
          return nil unless user_sandbox
        end

        # get admin role
        #admin_role = @service_connection.roles.all(name:'admin').first
        admin_role = role('admin')
        # assign admin role to user for sandbox
        user_sandbox.grant_role_to_user(admin_role.id,user.id)

        return user_sandbox
      rescue => e
        p e
        return nil
      end
    end

    def roles
      @roles ||= service_user.roles
    end
  
    def role(name)
      roles.select {|r| r.name==name}.first
    end
    
    def service_user
      @service_user ||= MonsoonOpenstackAuth.api_client(@region).connection_driver.connection
    end
  end
end