module Identity
  module Driver
    # Compute calls
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper

      def initialize(params_or_driver)
        # support initialization by given driver
        if params_or_driver.is_a?(::Fog::Identity::OpenStack::V3::Real)
          @fog = params_or_driver
        else
          super(params_or_driver)
          @fog = ::Fog::Identity::OpenStack::V3.new(auth_params)
          # @fog = ::Fog::IdentityV3::OpenStack.new(auth_params)
        end
      end

      def handle_api_errors?
        true
      end

      ########################### IMAGES #############################
      def auth_projects(filter={})
        handle_response{ @fog.auth_projects(filter).body['projects'] }
      end

      def projects(filter={})
        handle_response{ @fog.list_projects(filter).body['projects'] }
      end

      def get_project(id,options=[])
        options=[options] unless options.is_a?(Array)
        handle_response{ @fog.get_project(id, options).body['project'] }
      end

      def create_project(params={})
        handle_response{ @fog.create_project(params).body['project'] }
      end

      def update_project(id,params={})
        handle_response{ @fog.update_project(id, params).body['project']}
      end

      def delete_project(id)
        handle_response{
          @fog.delete_project(id)
          true
        }
      end

      def project_user_roles(project_id,user_id)
        handle_response{
          @fog.list_project_user_roles(project_id, user_id).body['roles']
        }
      end

      def grant_project_user_role(project_id,user_id,role_id)
        handle_response{
          @fog.grant_project_user_role(project_id, user_id, role_id)
        }
      end

      def check_project_user_role(project_id,user_id,role_id)
         handle_response{
           begin
             @fog.check_project_user_role(project_id, user_id, role_id)
           rescue Fog::Identity::OpenStack::NotFound
             return false
           end
           return true
         }
      end

      def revoke_project_user_role(project_id,user_id,role_id)
        handle_response{
          @fog.revoke_project_user_role(project_id, user_id, role_id)
        }
      end

      def project_group_roles(project_id,group_id)
        handle_response{
          @fog.list_project_group_roles(project_id, group_id).body['roles']
        }
      end

      def grant_project_group_role(project_id,group_id,role_id)
        handle_response{
          @fog.grant_project_group_role(project_id, group_id, role_id)
        }
      end

      def check_project_group_role(project_id,group_id,role_id)
        handle_response{
          begin
            @fog.check_project_group_role(project_id, group_id, role_id)
          rescue Fog::Identity::OpenStack::NotFound
            return false
          end
          return true
        }
      end

      def revoke_project_group_role(project_id,group_id,role_id)
        handle_response{
          @fog.revoke_project_group_role(project_id, group_id, role_id)
        }
      end

      ##################### DOMAINS #########################
      def domains(filter={})
        handle_response{
          @fog.list_domains(filter).body['domains']
        }
      end

      def create_domain(params={})
        handle_response{ @fog.create_domain(attributes).body['domain'] }
      end

      def get_domain(id)
        handle_response{ @fog.get_domain(id).body['domain'] }
      end

      def update_domain(id,params={})
        handle_response{ @fog.update_domain(id,params).body['domain']}
      end

      def delete_domain(id)
        handle_response{
          @fog.delete_domain(self.id)
          true
        }
      end

      def domain_user_roles(domain_id,user_id)
        handle_response{
          @fog.list_domain_user_roles(domain_id, user_id).body['roles']
        }
      end

      def grant_domain_user_role(domain_id,user_id,role_id)
        handle_response{
          @fog.grant_domain_user_role(domain_id, user_id, role_id)
        }
      end

      def check_domain_user_role(domain_id,user_id,role_id)
        handle_response{
          begin
            @fog.check_domain_user_role(domain_id, user_id, role_id)
          rescue Fog::Identity::OpenStack::NotFound
            return false
          end
          return true
        }
      end

      def revoke_domain_user_role(domain_id,user_id,role_id)
        handle_response{
          @fog.revoke_domain_user_role(domain_id, user_id, role_id)
        }
      end

      # def domain_group_roles(domain_id,group_id)
      #   raise ServiceLayer::Errors::NotImplemented
      # end
      #
      # def grant_domain_group_role(domain_id,group_id,role_id)
      #   raise ServiceLayer::Errors::NotImplemented
      # end
      #
      # def check_domain_group_role(domain_id,group_id,role_id)
      #   raise ServiceLayer::Errors::NotImplemented
      # end
      #
      # def revoke_domain_group_role(domain_id,group_id,role_id)
      #   raise ServiceLayer::Errors::NotImplemented
      # end

      def auth_domains(filter={})
        handle_response{ @fog.auth_domains(filter).body['domains'] }
      end


      ##################### CREDENTIALS #########################
      def os_credentials(filter={})
        handle_response{ @fog.list_os_credentials(filter).body['credentials'] }
      end

      def get_os_credential(id)
        handle_response{ @fog.get_os_credential(id).body['credential'] }
      end

      def create_os_credential(params = {})
        handle_response{ @fog.create_os_credential(params).body['credential'] }
      end

      def update_os_credential(id, params={})
        handle_response{ @fog.update_os_credential(id, params).body['credential'] }
      end

      def delete_os_credential(id)
        handle_response{
          @fog.delete_os_credential(id)
          true
        }
      end

      ##################### USERS #########################
      def users(filter={})
        handle_response{ @fog.list_users(filter).body['users'] }
      end

      def get_user(id)
        handle_response{ @fog.get_user(id).body['user'] }
      end

      def create_user(params = {})
        handle_response{ @fog.create_user(params).body['user'] }
      end

      def update_user(id, params={})
        handle_response{ @fog.update_user(id, params).body['user'] }
      end

      def delete_user(id)
        handle_response{ @fog.delete_user(id); true }
      end

      def user_groups(user_id)
        handle_response{ @fog.list_user_groups(user_id).body['groups'] }
      end

      def user_projects(user_id)
        handle_response{ @fog.list_user_projects(user_id).body['projects'] }
      end

      ######################## ROLES ##########################
      def roles(filter={})
        handle_response{ @fog.list_roles(filter).body['roles'] }
      end

      def create_role(params={})
        raise ServiceLayer::Errors::NotImplemented
      end

      def get_role(id)
        handle_response{ @fog.get_role(id).body['role']}
      end

      def role_assignments(filter={})
        handle_response{ @fog.list_role_assignments(filter).body['role_assignments'] }
      end

      def delete_role(id)
        handle_response{ @fog.delete_role(id); true }
      end

      ##################### GROUPS ####################
      def groups(filter={})
        handle_response{@fog.list_groups(filter).body['groups']}
      end
      
      def group_members(group_id,filter={})
        handle_response{@fog.list_group_users(group_id,filter).body['users']}
      end
      
      def add_group_member(group_id,user_id)
        handle_response{@fog.add_user_to_group(group_id,user_id)}
      end
      
      def remove_group_member(group_id,user_id)
        handle_response{@fog.remove_user_from_group(group_id, user_id)}
      end
      
      def get_group(id)
        handle_response{@fog.get_group(id).body['group']}
      end

      ######################### TOKENS ########################
      def authenticate(auth)
        handle_response{
          response = @fog.token_authenticate(auth)
          #response.headers['X-Subject-Token'])
          response.body['token']
        }
      end

      def validate(subject_token)
        handle_response{
          response = @fog.token_validate(subject_token)
          #response.headers['X-Subject-Token'])
          response.body['token']
        }
      end

      def check(subject_token)
        handle_response{
          @fog.token_check(subject_token)
          return true
        }
      end

      def revoke(subject_token)
        handle_response{
          @fog.token_revoke(subject_token)
          return true
        }
      end
    end
  end
end
