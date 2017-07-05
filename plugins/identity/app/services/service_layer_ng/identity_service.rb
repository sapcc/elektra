# frozen_string_literal: true

module ServiceLayerNg

  # This class implements the identity api
  class IdentityService < Core::ServiceLayerNg::Service
    include User
    include Project
    include Domain

    def available?(_action_name_sym = nil)
      !current_user.service_url('identity', region: region).nil?
    end


    def grant_project_user_role_by_role_name(project_id, user_id, role_name)
      role = service_user.find_role_by_name(role_name)
      driver.grant_project_user_role(project_id, user_id, role.id)
      role
    end

    def grant_project_user_role(project_id, user_id, role_id)
      driver.grant_project_user_role(project_id, user_id, role_id)
    end

    def revoke_project_user_role(project_id, user_id, role_id)
      driver.revoke_project_user_role(project_id, user_id, role_id)
    end

    def grant_project_group_role(project_id, group_id, role_id)
      driver.grant_project_group_role(project_id, group_id, role_id)
    end

    def revoke_project_group_role(project_id, group_id, role_id)
      driver.revoke_project_group_role(project_id, group_id, role_id)
    end

    ##################### CREDENTIALS #########################
    def new_credential(attributes={})
      Identity::OsCredential.new(@driver, attributes)
    end

    def find_credential(id=nil)
      return nil if id.blank?
      driver.map_to(Identity::OsCredential).get_os_credential(id)
    end

    def credentials(options={})
      @user_credentials ||= driver.map_to(Identity::OsCredential).os_credentials(user_id: @current_user.id)
    end

    ####################### ROLES ###########################
    # current_user roles
    def roles
      @roles ||= driver.map_to(Identity::Role).roles
    end

    def user_groups
      driver.map_to(Identity::Group).user_groups(@current_user.id)
    end

    def groups(filter={})
      driver.map_to(Identity::Group).groups(filter)
    end

    def create_group(attributes)
      driver.map_to(Identity::Group).create_group(attributes)
    end

    def delete_group(group_id)
      driver.delete_group(group_id)
    end

    def new_group(attributes={})
      Identity::Group.new(driver, attributes)
    end

    def find_group(id)
      driver.map_to(Identity::Group).get_group(id)
    end

    def group_members(group_id,filter={})
      driver.map_to(Identity::User).group_members(group_id,filter)
    end

    def add_group_member(group_id,user_id)
      driver.add_group_member(group_id,user_id)
    end

    def remove_group_member(group_id,user_id)
      driver.remove_group_member(group_id,user_id)
    end

    def find_role(id)
      return nil if id.blank?
      roles.select { |r| r.id==id }.first
    end

    def find_role_by_name(name)
      roles.select { |r| r.name==name }.first
    end

    def role_assignments(filter={})
      driver.map_to(Identity::RoleAssignment).role_assignments(filter)
    end

    def grant_domain_user_role(domain_id, user_id, role_id)
      driver.grant_domain_user_role(domain_id, user_id, role_id)
    end

    def revoke_domain_user_role(domain_id, user_id, role_id)
      driver.revoke_domain_user_role(domain_id, user_id, role_id)
    end

  end
end
