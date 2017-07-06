# frozen_string_literal: true

module ServiceLayerNg
  # This module implements Openstack Project API
  module Project
    def has_projects?
      api.identity.get_available_project_scopes.data.length.positive?
    end

    def new_project(attributes = {})
      map_to(Identity::Project, attributes)
    end

    def find_project!(id = nil, options = {})
      return nil if id.blank?
      api.identity.show_project_details(id, options).map_to(Identity::Project)
    end

    def find_project(id = nil, options = {})
      find_project!(id, options)
    rescue
      nil
    end

    def user_projects(user_id, filter = {})
      api.identity
         .list_projects_for_user(user_id, filter)
         .map_to(Identity::Project)
    end

    def projects_by_user_id(user_id)
      api.identity.list_projects_for_user(user_id).map_to(Identity::Project)
    end

    def auth_projects(domain_id = nil)
      # caching
      @auth_projects ||= api.identity
                            .get_available_project_scopes
                            .map_to(Identity::Project)

      return @auth_projects if domain_id.nil?
      @auth_projects.select { |project| project.domain_id == domain_id }
    end

    def auth_projects_tree(projects = auth_projects)
      Identity::ProjectTree.new(projects)
    end

    def projects(filter = {})
      api.identity.list_projects(filter).map_to(Identity::Project)
    end

    def find_project_by_name_or_id(domain_id, name_or_id)
      projects(domain_id: domain_id, name: name_or_id).first ||
        find_project(name_or_id)
    end

    ################### MODEL INTERFACE #################
    # This method is used by model.
    # It has to return the data hash.
    def update_project(id, params)
      api.identity.update_project(id, project: params).data
    end

    # This method is used by model.
    def delete_project(id)
      api.identity.delete_project(id)
    end
  end
end
