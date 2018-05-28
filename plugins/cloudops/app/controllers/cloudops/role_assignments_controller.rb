# frozen_string_literal: true

module Cloudops
  class RoleAssignmentsController < Cloudops::ApplicationController
    def index
      role_assignments = services.identity.role_assignments(
        'scope.project.id' => params[:scope_project_id], include_names: true
      )

      user_roles = extend_role_assignments_data(role_assignments)

      render json: { roles: user_roles }
    end

    def available_roles
      roles = services.identity.roles.sort_by(&:name)
      roles.each do |role|
        role.description = I18n.t("roles.#{role.name}", default: role.name.try(:titleize)) + " (#{role.name})"
      end

      render json: { roles: roles }
    end

    def update
      scope_project_id = params[:scope_project_id]
      user_id = params[:user_id]
      new_roles = params[:roles]

      # do not update role assignments if user or project are blank
      if scope_project_id.blank? || user_id.blank?
        render json: {roles: []}
        return
      end

      # get current project user role assignments from API
      current_role_assignments = services.identity.role_assignments(
        'scope.project.id' => scope_project_id,
        'user.id' => user_id
      )

      # get role ids from current role assignments
      current_roles = current_role_assignments.collect do |role_assignment|
        role_assignment.role['id']
      end

      # calculate differences
      roles_to_be_added = new_roles - current_roles
      roles_to_be_removed = current_roles - new_roles

      # add new user roles to project
      roles_to_be_added.each do |role_id|
        services.identity.grant_project_user_role(
          scope_project_id,user_id, role_id
        )
      end

      # remove obsolete user roles from project
      roles_to_be_removed.each do |role_id|
        services.identity.revoke_project_user_role(
          scope_project_id,user_id, role_id
        )
      end

      # reload uproject user role assignments
      new_role_assignments = services.identity.role_assignments(
        'scope.project.id' => scope_project_id,
        'user.id' => user_id, include_names: true
      )

      new_roles = extend_role_assignments_data(new_role_assignments)

      render json: { roles: new_roles.first}
    end

    private

    def extend_role_assignments_data(role_assignments)
      user_roles = role_assignments.each_with_object({}) do |assignment, map|
        next if assignment.user.blank?
        map[assignment.user['id']] ||= {}
        map[assignment.user['id']]['user'] = assignment.user
        map[assignment.user['id']]['roles'] ||= []
        role_name = assignment.role['name']
        assignment.role['description'] = I18n.t("roles.#{role_name}", default: role_name.try(:titleize)) + " (#{role_name})"
        map[assignment.user['id']]['roles'] << assignment.role
      end

      ObjectCache.where(cached_object_type: 'user', id: user_roles.keys).pluck(
        :id, :payload
      ).each do |data|
        if user_roles[data[0]] && user_roles[data[0]]['user']
          user_roles[data[0]]['user']['description'] = data[1]['description']
        end
      end

      user_roles.values.sort_by {|r| r['user']['name']}
    end
  end
end
