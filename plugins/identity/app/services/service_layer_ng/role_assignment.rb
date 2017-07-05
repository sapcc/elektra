# frozen_string_literal: true

module ServiceLayerNg
  # This module implements Openstack RoleAssignment API
  module RoleAssignment
    def role_assignments(filter = {})
      effective = filter.delete(:effective) || filter.delete('effective')
      assignments = api.identity.list_role_assignments(filter)
                       .map_to(Identity::RoleAssignmentNg)
      # return if no effective filter required
      return assignments unless effective

      aggregate_group_role_assignments(assignments)
    end

    def aggregate_group_role_assignments(role_assignments)
      role_assignments.each_with_object([]) do |ra, array|
        if ra.user.present?
          array << ra
        elsif ra.group.present?
          group_members(ra.group['id']).data.each do |user|
            array << map_to(Identity::RoleAssignmentNg,
                            'role' => ra.role,
                            'scope' => ra.scope,
                            'user' => { 'id' => user.id })
          end
        end
      end
    end

    def grant_project_user_role_by_role_name(project_id, user_id, role_name)
      role = find_role_by_name(role_name)
      grant_project_user_role(project_id, user_id, role.id)
    end

    def grant_project_user_role(project_id, user_id, role_id)
      api.identity.assign_role_to_user_on_project(project_id, user_id, role_id)
    end

    def revoke_project_user_role(project_id, user_id, role_id)
      api.identity.unassign_role_from_user_on_project(
        project_id, user_id, role_id
      )
    end

    def grant_project_group_role(project_id, group_id, role_id)
      api.identity.assign_role_to_group_on_project(
        project_id, group_id, role_id
      )
    end

    def revoke_project_group_role(project_id, group_id, role_id)
      api.identity.unassign_role_from_group_on_project(
        project_id, group_id, role_id
      )
    end

    def grant_domain_user_role(domain_id, user_id, role_id)
      api.identity.assign_role_to_user_on_domain(domain_id, user_id, role_id)
    end

    def revoke_domain_user_role(domain_id, user_id, role_id)
      api.identity.unassigns_role_from_user_on_domain(
        domain_id, user_id, role_id
      )
    end
  end
end
