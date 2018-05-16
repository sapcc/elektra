# frozen_string_literal: true

module Cloudops
  class SearchController < ApplicationController
    layout "cloudops"

    def index
      page = (params[:page] || 1).to_i
      per_page = 30

      scope = ::ObjectCache.all

      # reduce scope to objects with the given type
      unless params[:type].blank?
        scope = scope.where(cached_object_type: params[:type])
      end

      # search objects by term
      scope = scope.search(params[:term]) unless params[:term].blank?
      # include associations domain and project (two more queries)
      scope = scope.includes(:domain, project: :domain)

      objects = scope.limit(per_page + 1).offset((page - 1) * per_page)
      total = objects.except(:offset, :limit, :order).count
      has_next = objects.length > per_page
      objects = objects.to_a
      objects.pop if has_next

      extend_object_payload_with_scope(objects)
      render json: { items: objects, hasNext: has_next, total: total }
    end

    def types
      render json: ::ObjectCache.distinct.pluck(:cached_object_type)
        .delete_if(&:blank?)
    end

    def show
      objects = ::ObjectCache.where(id: params[:id])
                         .includes(:domain, project: :domain)
      extend_object_payload_with_scope(objects)
      render json: objects.first
    end

    def projects
      page = (params[:page] || 1).to_i
      per_page = 30

      domain = params[:domain]
      project = params[:project]


      domain_ids = ObjectCache.where(cached_object_type: 'domain').where(
        ['name ILIKE :domain OR id ILIKE :domain', domain: "%#{domain}%"]
      ).pluck(:id) unless domain.blank?

      projects = ObjectCache.where(cached_object_type: 'project')
      projects = projects.where(domain_id: domain_ids) if domain_ids
      projects = projects.where(
        ['name ILIKE :project OR id ILIKE :project', project: "%#{project}%"]
      ) unless project.blank?


      projects = projects.limit(per_page + 1).offset(page - 1)
      total = projects.except(:offset, :limit, :order).count
      has_next = projects.length > per_page
      projects = projects.to_a
      projects.pop if has_next
      extend_object_payload_with_scope(projects)

      render json: { projects: projects, hasNext: has_next, total: total }
    end

    private

    def extend_object_payload_with_scope(objects)
      objects.each do |obj|
        project = obj.cached_object_type == 'project' ? obj : obj.project
        domain = project ? project.domain : obj.domain

        obj.payload['scope'] = {
          'domain_id' => domain ? domain.id : nil,
          'domain_name' => domain ? domain.name : nil
        }

        if obj.cached_object_type == 'project'
          # type of object is project -> use parent project data for scope
          if obj.payload['parent_id'] != obj.payload['domain_id']
            # parent project is presented
            obj.payload['scope']['project_id'] = obj.payload['parent_id']
            obj.payload['scope']['project_name'] = obj.payload['parent_name']
          end
        else
          # object belongs to a project
          obj.payload['scope']['project_id'] = project ? project.id : nil
          obj.payload['scope']['project_name'] = project ? project.name : nil
        end
      end
    end
  end
end
