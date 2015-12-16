module Admin
  class IdentityService
      
    class << self  
      def create_user_domain_role(current_user,role_name)
        return false if current_user.nil? or role_name.nil?
        member_role = admin_identity.find_role_by_name(role_name)
        admin_identity.grant_domain_user_role(current_user.user_domain_id,current_user.id,member_role.id)
      end
        
      def method_missing(method_sym, *arguments, &block)
        if admin_identity.respond_to?(method_sym)
          admin_identity.send(method_sym,*arguments, &block)
        else
          super
        end
      end

      # Returns admins for the given scope (e.g. project_id: PROJECT_ID, domain_id: DOMAIN_ID)
      # This method looks recursively for project, parent_projects and domain admins until it finds at least one. 
      # It should always return a non empty list (at least the domain admins).
      def list_scope_admins(scope={})
        role = admin_identity.find_role_by_name('admin') rescue nil
        list_scope_assigned_users(scope.merge(role: role))
      end
      
      # Returns assigned users for the given scope and role (e.g. project_id: PROJECT_ID, domain_id: DOMAIN_ID, role: ROLE)
      # This method looks recursively for assigned users of project, parent_projects and domain. 
      def list_scope_assigned_users(options={})
        admins      = []
        project_id  = options[:project_id]
        domain_id   = options[:domain_id]
        role        = options[:role]
        
        # do nothing if role is nil
        return admins if role.nil?
        
        if project_id # project_id is presented
          # get role_assignments for this project_id
          role_assignments = admin_identity.role_assignments("scope.project.id"=>project_id,"role.id"=>role.id) rescue []
          # load users (not very performant but there is no other option to get users by ids)
          role_assignments.collect{|r| admins << admin_identity.find_user(r.user_id)  }
          
          if admins.length==0 # no admins for this project_id found
            # load project
            project = admin_identity.find_project(project_id) rescue nil
            if project 
              # try to get admins recursively by parent_id 
              admins = list_scope_assigned_users(project_id: project.parent_id, domain_id: project.domain_id, role: role)
            end  
          end
        elsif domain_id # project_id is nil but domain_id is presented
          # get role_assignments for this domain_id
          role_assignments = admin_identity.role_assignments("scope.domain.id"=>domain_id,"role.id"=>role.id, effective: true) rescue []
          # load users
          role_assignments.collect{|r|  admins << admin_identity.find_user(r.user_id) }       
        end
        
        return admins.delete_if {|a| a.id == nil} # delete crap
      end
      
      def admin_identity
        return @admin_identity if @admin_identity_expires_at and @admin_identity_expires_at>Time.now

        # get default region
        region = MonsoonOpenstackAuth.configuration.default_region
        # authenticate service user
        service_user = MonsoonOpenstackAuth.api_client(region).auth_user(
          ENV['MONSOON_OPENSTACK_AUTH_API_USERID'],
          ENV['MONSOON_OPENSTACK_AUTH_API_PASSWORD'],
          domain_name: ENV['MONSOON_OPENSTACK_AUTH_API_DOMAIN'],
          scoped_token: true # fog requires a domain scoped token -> scope: { domain: {name: DOMAIN} }
        )
        
        @admin_identity = DomainModelServiceLayer::ServicesManager.service(:identity, {
          region: region,
          token: service_user.token
        })

        if @admin_identity
          @admin_identity_expires_at = service_user.token_expires_at
        end
        @admin_identity
                  
        # region = MonsoonOpenstackAuth.configuration.default_region
        # servce_user_connection = MonsoonOpenstackAuth.api_client(region).connection_driver.connection
        #
        # if @admin_identity.nil? or @admin_identity.token!=servce_user_connection.auth_token
        #   @admin_identity = DomainModelServiceLayer::ServicesManager.service(:identity,{
        #     region: region,
        #     token: servce_user_connection.auth_token
        #   })
        # end
        # @admin_identity
      end
    end
  end
end