module Identity
  module Driver
    # Identity calls
    class Interface < DomainModelServiceLayer::Driver::Base
      ##################### PROJECTS ########################
      def create_project(params={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def projects(filter={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def get_project(id,options=[])
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def update_project(id,params={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def delete_project(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def project_user_roles(project_id,user_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def grant_project_user_role(project_id,user_id,role_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def check_project_user_role(project_id,user_id,role_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def revoke_project_user_role(project_id,user_id,role_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def project_group_roles(project_id,group_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def grant_project_group_role(project_id,group_id,role_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def check_project_group_role(project_id,group_id,role_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def revoke_project_group_role(project_id,group_id,role_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def auth_projects(filter={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    

      ##################### DOMAINS #########################
      def domains(filter={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def create_domain(params={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def get_domain(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def update_domain(id,params={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def delete_domain(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def domain_user_roles(domain_id,user_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def grant_domain_user_role(domain_id,user_id,role_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def check_domain_user_role(domain_id,user_id,role_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def revoke_domain_user_role(domain_id,user_id,role_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def domain_group_roles(domain_id,group_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def grant_domain_group_role(domain_id,group_id,role_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def check_domain_group_role(domain_id,group_id,role_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def revoke_domain_group_role(domain_id,group_id,role_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def auth_domains(filter={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end


      ##################### CREDENTIALS #########################
      def os_credentials(filter={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def get_os_credential(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def create_os_credential(params = {})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def update_os_credential(id, params={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def delete_os_credential(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      ##################### USERS #########################
      def users(filter={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def get_user(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def create_user(params = {})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def update_user(id, params={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def delete_user(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def user_groups(user_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def user_projects(user_id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
    
      ######################## ROLES ##########################
      def roles(filter={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def create_role(name)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def get_role(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def role_assignments(filter={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      def delete_role(id)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
      ######################### TOKENS #########################
      def authenticate(auth)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def validate(subject_token)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def check(subject_token)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def revoke(subject_token)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end
    
    end 
  end
end