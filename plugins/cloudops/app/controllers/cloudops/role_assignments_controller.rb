# frozen_string_literal: true

module Cloudops
  class RoleAssignmentsController < ApplicationController
    def index
      role_assignments = services.identity.role_assignments(
        'scope.project.id' => params[:scope_project_id], include_names: true
      )

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


      render json: { roles: user_roles.values }
    end

    def available_roles
      roles = services.identity.roles.sort_by(&:name)
      roles.each do |role|
        role.description = I18n.t("roles.#{role.name}", default: role.name.try(:titleize)) + " (#{role.name})"
      end

      render json: { roles: roles }
    end
  end
end
