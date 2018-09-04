# frozen_string_literal: true

module ServiceLayer
  module IdentityServices
    # This module implements Openstack RoleAssignment API
    module RoleAssignment
      def role_assignment_map
        @role_assignment_map ||= class_map_proc(Identity::RoleAssignment)
      end

      def origin_role_assignments(filter = {})
        elektron_identity.get('role_assignments', filter).map_to(
          'body.role_assignments', &role_assignment_map
        )
      end

      def role_assignments(filter = {})
        effective = filter.delete(:effective) || filter.delete('effective')
        # if effective is true remove user_id from filter to find also groups.
        user_id = filter.delete('user.id') if effective

        assignments = elektron_identity.get('role_assignments', filter).map_to(
          'body.role_assignments', &role_assignment_map
        )
        # return if no effective filter required
        return assignments unless effective

        result = aggregate_group_role_assignments(assignments)
        # select user role assignments unless user_id is nil
        result = result.select { |a| a.user['id'] == user_id } if user_id
        result
      end

      def aggregate_group_role_assignments(role_assignments)
        role_assignments.each_with_object([]) do |ra, array|
          if ra.user.present?
            array << ra
          elsif ra.group.present?
            group_users = elektron_identity.get(
              "groups/#{ra.group['id']}/users"
            ).body['users']

            group_users.each do |user|
              array << role_assignment_map.call(
                'role' => ra.role,
                'scope' => ra.scope,
                'user' => { 'id' => user['id'] }
              )
            end
          end
        end
      end

      def grant_project_user_role_by_role_name(project_id, user_id, role_name)
        role = find_role_by_name(role_name)
        grant_project_user_role(project_id, user_id, role.id)
      end

      def grant_project_user_role!(project_id, user_id, role_id)
        elektron_identity.put(
          "projects/#{project_id}/users/#{user_id}/roles/#{role_id}"
        )
      end

      def grant_project_user_role(project_id, user_id, role_id)
        grant_project_user_role!(project_id, user_id, role_id)
      rescue Elektron::Errors::ApiResponse
        false
      end

      def revoke_project_user_role!(project_id, user_id, role_id)
        elektron_identity.delete(
          "projects/#{project_id}/users/#{user_id}/roles/#{role_id}"
        )
      end

      def revoke_project_user_role(project_id, user_id, role_id)
        revoke_project_user_role!(project_id, user_id, role_id)
      rescue Elektron::Errors::ApiResponse
        false
      end

      def grant_project_group_role!(project_id, group_id, role_id)
        elektron_identity.put(
          "projects/#{project_id}/groups/#{group_id}/roles/#{role_id}"
        )
      end

      def grant_project_group_role(project_id, group_id, role_id)
        grant_project_group_role!(project_id, group_id, role_id)
      rescue Elektron::Errors::ApiResponse
        false
      end

      def revoke_project_group_role!(project_id, group_id, role_id)
        elektron_identity.delete(
          "projects/#{project_id}/groups/#{group_id}/roles/#{role_id}",
          http_client: { read_timeout: 180 }
        )
      end

      def revoke_project_group_role(project_id, group_id, role_id)
        revoke_project_group_role!(project_id, group_id, role_id)
      rescue Elektron::Errors::ApiResponse
        false
      end

      def grant_domain_user_role!(domain_id, user_id, role_id)
        elektron_identity.put(
          "domains/#{domain_id}/users/#{user_id}/roles/#{role_id}"
        )
      end

      def grant_domain_user_role(domain_id, user_id, role_id)
        grant_domain_user_role!(domain_id, user_id, role_id)
      rescue Elektron::Errors::ApiResponse
        false
      end

      def revoke_domain_user_role!(domain_id, user_id, role_id)
        elektron_identity.delete(
          "domains/#{domain_id}/users/#{user_id}/roles/#{role_id}"
        )
      end

      def revoke_domain_user_role(domain_id, user_id, role_id)
        revoke_domain_user_role!(domain_id, user_id, role_id)
      rescue Elektron::Errors::ApiResponse
        false
      end
    end
  end
end
