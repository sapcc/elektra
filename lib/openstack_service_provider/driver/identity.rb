module OpenstackServiceProvider
  module Driver
    # Identity calls
    class Identity < OpenstackServiceProvider::Driver::Base
      ##################### PROJECTS ########################
      def create_project(params={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def projects(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def get_project(id,options=[])
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def update_project(id,params={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def delete_project(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def project_user_roles(project_id,user_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def grant_project_user_role(project_id,user_id,role_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def check_project_user_role(project_id,user_id,role_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def revoke_project_user_role(project_id,user_id,role_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def project_group_roles(project_id,group_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def grant_project_group_role(project_id,group_id,role_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def check_project_group_role(project_id,group_id,role_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def revoke_project_group_role(project_id,group_id,role_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def auth_projects(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      

      ##################### DOMAINS #########################
      def domains(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def create_domain(params={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def get_domain(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def update_domain(id,params={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def delete_domain(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def domain_user_roles(domain_id,user_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def grant_domain_user_role(domain_id,user_id,role_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def check_domain_user_role(domain_id,user_id,role_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def revoke_domain_user_role(domain_id,user_id,role_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def domain_group_roles(domain_id,group_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def grant_domain_group_role(domain_id,group_id,role_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def check_domain_group_role(domain_id,group_id,role_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def revoke_domain_group_role(domain_id,group_id,role_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def auth_domains(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end


      ##################### CREDENTIALS #########################
      def os_credentials(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def get_os_credential(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def create_os_credential(params = {})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def update_os_credential(id, params={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def delete_os_credential(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      ##################### USERS #########################
      def users(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def get_user(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def create_user(params = {})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def update_user(id, params={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def delete_user(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def user_groups(user_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def user_projects(user_id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      
      ######################## ROLES ##########################
      def roles(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def create_role(name)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def get_role(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end

      def role_assignments(filter={})
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
      
      def delete_role(id)
        raise OpenstackServiceProvider::Errors::NotImplemented
      end
    end 
  end
end