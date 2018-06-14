# frozen_string_literal: true

module Cloudops
  class RoleAssignmentsController < Cloudops::ApplicationController
    def index
      role_assignments = services.identity.role_assignments(
        'scope.project.id' => params[:scope_project_id], include_names: true
      )

      render json: { roles: group_and_extend_role_assignments(role_assignments) }
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
      group_id = params[:group_id]
      new_roles = params[:roles]

      # do not update role assignments if user or project are blank
      if scope_project_id.blank? || (user_id.blank? && group_id.blank?)
        render json: { roles: [] }
        return
      end

      new_roles = if user_id.present?
                    update_project_role_assignments(
                      scope_project_id, 'user', user_id, new_roles
                    )
                  elsif group_id.present?
                    update_project_role_assignments(
                      scope_project_id, 'group', group_id, new_roles
                    )
                  end
      render json: { roles: new_roles }
    end

    private

    # This method removes obsolete and assigns new roles to project.
    def update_project_role_assignments(scope_project_id, owner_type, owner_id, new_roles)
      # only user and group project role assignments are allowed
      unless %w[user group].include?(owner_type)
        raise StandardError, 'Unknown owner type'
      end

      filter_options = {
        'scope.project.id' => scope_project_id, "#{owner_type}.id" => owner_id
      }

      # get current project owner role assignments from API
      current_role_assignments = services.identity.role_assignments(
        filter_options
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
        services.identity.send(
          "grant_project_#{owner_type}_role",
          scope_project_id, owner_id, role_id
        )
      end

      # remove obsolete user roles from project
      roles_to_be_removed.each do |role_id|
        services.identity.send(
          "revoke_project_#{owner_type}_role",
          scope_project_id, owner_id, role_id
        )
      end

      # reload uproject user role assignments
      new_role_assignments = services.identity.role_assignments(
        filter_options.merge(include_names: true)
      )

      group_and_extend_role_assignments(new_role_assignments)
    end

    # This method groups role assignments by user and group.
    # Further it extends role and owner descriptions using data from cache.
    # Returns an array of maps.
    def group_and_extend_role_assignments(role_assignments)
      owner_ids = role_assignments.collect do |ra|
        (ra.user || ra.group || {})['id']
      end.uniq

      # get user or group descriptions from cache
      # map: id => description
      owner_descriptions = ObjectCache.where(id: owner_ids).pluck(:id, :payload)
                                      .each_with_object({}) do |data, map|
                                        map[data[0]] = data[1]['description']
                                      end

      role_assignments.each_with_object({}) do |ra, map|
        owner_type = ''
        owner_type = 'user' if ra.user.present?
        owner_type = 'group' if ra.group.present?
        owner = (ra.user || ra.group || {})

        role_name = ra.role['name']
        # extend role description using translations
        ra.role['description'] = I18n.t(
          "roles.#{role_name}", default: role_name.try(:titleize)
        ) + " (#{role_name})"

        owner['description'] = owner_descriptions[owner['id']]
        # build the map: owner id => {owner, roles}
        map[owner['id']] ||= {}
        map[owner['id']][owner_type] = owner
        map[owner['id']]['roles'] ||= []
        map[owner['id']]['roles'] << ra.role
      end.values
    end
  end
end
