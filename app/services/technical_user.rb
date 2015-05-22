class TechnicalUser
  def initialize(auth_session)
    @service_connection = MonsoonOpenstackAuth.api_client(auth_session.region).connection_driver.connection
    @user = auth_session.user
    @domain_id = @user.domain_id
  end
  
  def create_user_sandbox
    begin
      name = "#{@user.name}_sandbox"
      user_sandbox = @service_connection.projects.all(name: name, domain_id: @domain_id).first
      
      unless user_sandbox
        # get root project (sandboxes)
        sandboxes = @service_connection.projects.all(name:'sandboxes',domain_id:@domain_id)    
        return nil unless sandboxes or sandboxes.length==0

        # create sandbox for user
        user_sandbox = sandboxes.create(domain_id: @domain_id, name: name, description: "#{@user.full_name}'s sandbox", enabled: true, parent_id: sandboxes.first.id)  
        return nil unless user_sandbox
      end
      
      # get admin role  
      admin_role = @service_connection.roles.all(name:'admin').first
      # assign admin role to user for sandbox
      user_sandbox.grant_role_to_user(admin_role.id,@user.id)
                    
      return user_sandbox
    rescue => e
      p e
      return nil
    end
  end
  
  def sandbox_exists?
    begin
      user_connection = @service_connection.users.find_by_id(@user.id)
      user_connection.projects.length>0
    rescue => e
      p e
    end
  end
end