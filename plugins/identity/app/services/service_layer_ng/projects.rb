# frozen_string_literal: true

module ServiceLayerNg
  # This module implements Openstack Project API
  module Projects
    def has_projects?
      api.identity.get_available_project_scopes.data.length.positive?
    end

    def new_project(attributes = {})
      map_to(Identity::Project, attributes)
    end

    def find_project(id = nil, options = {})
      return nil if id.blank?
      api.identity.show_project_details(id, options).map_to(Identity::ProjectNg)
    end

    def projects_by_user_id(user_id)
      api.identity.list_projects_for_user(user_id).map_to(Identity::ProjectNg)
    end

    def auth_projects(domain_id = nil)
      # caching
      @auth_projects ||= api.identity
                            .get_available_project_scopes
                            .map_to(Identity::ProjectNg)

      return @auth_projects if domain_id.nil?
      @auth_projects.select { |project| project.domain_id == domain_id }
    end

    def auth_projects_tree(projects = auth_projects)
      projects.try(:collect!) do |project|
        if project.is_a?(Identity::ProjectNg)
          project
        else
          map_to(Identity::ProjectNg, project.attributes.merge(id: project.id))
        end
      end

      @projects_tree ||= Rails.cache.fetch(
        "#{current_user.token}/auth_projects_tree", expires_in: 60.seconds
      ) do
        Identity::ProjectTree.new(projects)
      end
    end

    def clear_auth_projects_tree_cache
      Rails.cache.delete("#{current_user.token}/auth_projects_tree")
    end

    def projects(filter = {})
      api.identity.list_projects(filter).map_to(Identity::ProjectNg)
    end
  end
end
