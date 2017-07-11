# frozen_string_literal: true

module ServiceLayerNg
  # This module implements Openstack User API
  module User
    def users(filter = {})
      api.identity.list_users(filter).map_to(Identity::User)
    end

    def find_user!(id)
      api.identity.show_user_details(id).map_to(Identity::User)
    end

    def find_user(id)
      find_user!(id)
    rescue
      nil
    end

    def new_user(attributes = {})
      map_to(Identity::User, attributes)
    end

    # A special case of list_scope_admins that returns a list of CC admins.
    def list_ccadmins
      list_scope_admins(domain_name: Rails.configuration.cloud_admin_domain)
    end

    def list_scope_resource_admins(scope = {})
      role = find_role_by_name('resource_admin')
      list_scope_assigned_users(scope.merge(role: role))
    end

    # Returns admins for the given scope (e.g. project_id: PROJECT_ID,
    # domain_id: DOMAIN_ID)
    # This method looks recursively for project, parent_projects and
    # domain admins until it finds at least one.
    # It should always return a non empty list (at least the domain admins).
    def list_scope_admins(scope = {})
      role = find_role_by_name('admin')
      list_scope_assigned_users(scope.merge(role: role))
    end

    ############### MODEL INTERFACE ####################
    # This method is used by model.
    def delete_user(id)
      api.identity.delete_user(id)
    end

    private

    def role_assignments_to_users(ras)
      ras.each_with_object([]) do |r, array|
        next if r.user['id'] == Rails.application.config.service_user_id
        admin = find_user(r.user['id'])
        array << admin if admin
      end
    end

    # Returns assigned users for the given scope and role (e.g.
    # project_id: PROJECT_ID, domain_id: DOMAIN_ID, role: ROLE)
    # This method looks recursively for assigned users of project,
    # parent_projects and domain.
    def list_scope_assigned_users(options = {})
      admins = []
      project_id = options[:project_id]
      domain_id = options[:domain_id]
      role = options[:role]
      raise_error = options[:raise_error]

      # do nothing if role is nil
      return admins if role.nil?
      begin
        if project_id # project_id is presented
          # get role_assignments for this project_id
          ras = role_assignments(
            'scope.project.id' => project_id, 'role.id' => role.id,
            effective: true, include_subtree: true
          )

          # load users (not very performant but there is no other option
          # to get users by ids)
          admins.concat(role_assignments_to_users(ras))

          if admins.length.zero? # no admins for this project_id found
            # load project
            project = find_project(project_id)
            if project
              # try to get admins recursively by parent_id
              admins = list_scope_assigned_users(project_id: project.parent_id,
                                                 domain_id: project.domain_id,
                                                 role: role)
            end
          end
        elsif domain_id # project_id is nil but domain_id is presented
          # get role_assignments for this domain_id
          ras = role_assignments('scope.domain.id' => domain_id,
                                 'role.id' => role.id, effective: true)
          # load users
          admins.concat(role_assignments_to_users(ras))
        end
      rescue => e
        raise e if raise_error
      end

      admins.delete_if { |a| a.id.nil? } # delete crap
    end
  end
end
