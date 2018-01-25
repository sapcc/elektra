# frozen_string_literal: true

module ServiceLayer
  module IdentityServices
    # This module implements Openstack Project API
    module Project
      def project_map
        @project_map ||= class_map_proc(Identity::Project)
      end

      def has_projects?
        auth_projects.length.positive?
      end

      def new_project(attributes = {})
        project_map.call(attributes)
      end

      def find_project!(id = nil, options = {})
        return nil if id.blank?
        elektron_identity.get("projects/#{id}", options).map_to(
          'body.project', &project_map
        )
      end

      def find_project(id = nil, options = {})
        find_project!(id, options)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def user_projects!(user_id, filter = {})
        elektron_identity.get("users/#{user_id}/projects", filter).map_to(
          'body.projects', &project_map
        )
      end

      def user_projects(user_id, filter = {})
        user_projects!(user_id, filter)
      rescue Elektron::Errors::ApiResponse
        []
      end

      def cached_project(id, filter = {})
        project_attrs = Rails.cache.fetch(
          "project/#{id}", expires_in: 1.minute
        ) do
          elektron_identity.get("projects/#{id}", filter).body['project']
        end
        project_attrs.collect do |data|
          project_map.call(data)
        end
      end

      def cached_user_projects(user_id, filter = {})
        user_domain_projects_data = Rails.cache.fetch(
          "user/#{user_id}/user_domain_projects", expires_in: 1.minute
        ) do
          elektron_identity.get("users/#{user_id}/projects", filter)
                           .body['projects']
        end || []
        user_domain_projects_data.collect do |project_attrs|
          project_map.call(project_attrs)
        end
      end

      def projects_by_user_id(user_id)
        elektron_identity.get("users/#{user_id}/projects").map_to(
          'body.projects', &project_map
        )
      end

      def auth_projects(domain_id = nil)
        # caching
        @auth_projects ||= elektron_identity.get('auth/projects').map_to(
          'body.projects', &project_map
        )
        return @auth_projects if domain_id.nil?
        @auth_projects.select { |project| project.domain_id == domain_id }
      end

      def auth_projects_tree(projects = auth_projects)
        Identity::ProjectTree.new(projects)
      end

      def projects(filter = {})
        elektron_identity.get('projects', filter).map_to(
          'body.projects', &project_map
        )
      end

      def find_project_by_name_or_id(domain_id, name_or_id)
        projects(domain_id: domain_id, name: name_or_id).first ||
          find_project(name_or_id)
      end

      ################### MODEL INTERFACE #################
      # This method is used by model.
      # It has to return the data hash.
      def create_project(params)
        elektron_identity.post('projects') do
          { project: params }
        end.body['project']
      end

      # This method is used by model.
      # It has to return the data hash.
      def update_project(id, params)
        elektron_identity.patch("projects/#{id}") do
          { project: params }
        end.body['project']
      end

      # This method is used by model.
      def delete_project(id)
        elektron_identity.delete("projects/#{id}")
      end
    end
  end
end
