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
    
      def list_project_admins(project_id)
      
      end
    
      # def list_domain_admins(domain_id)
      #
      # end
      #
      # def list_project_and_domain_admins(project_id,domain_id)
      #
      # end
      
      # def list_project_users(project_id,role_name)
      #
      # end
      #
      
      def admin_identity
        region = MonsoonOpenstackAuth.configuration.default_region
        servce_user_connection = MonsoonOpenstackAuth.api_client(region).connection_driver.connection
    
        if @admin_identity.nil? or @admin_identity.token!=servce_user_connection.auth_token      
          @admin_identity = DomainModelServiceLayer::ServicesManager.service(:identity,{
            region: region,
            token: servce_user_connection.auth_token
          })
        end
        @admin_identity
      end
    end
  end
end