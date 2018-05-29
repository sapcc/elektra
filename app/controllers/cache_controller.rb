# frozen_string_literal: true

class CacheController < ::ApplicationController
  def index
    page = (params[:page] || 1).to_i

    items = ObjectCache.find_objects(
      type: params[:type],
      term: params[:term],
      include_scope: true,
      paginate: { page: page, per_page: 30}
    ) { |scope| scope.order(:name) }

    render json: { items: items, total: items.total, has_next: items.has_next }
  end

  def show
    objects = ObjectCache.find_objects(include_scope: true) do |scope|
      scope.where(id: params[:id])
    end

    render json: objects.first
  end

  def types
    render json: ::ObjectCache.distinct.pluck(:cached_object_type)
                              .delete_if(&:blank?)
  end

  def domain_projects
    page = (params[:page] || 1).to_i

    domain = options[:domain]
    project = options[:project]

    items = ObjectCache.find_objects(
      paginate: { page: page, per_page: 30 },
      include_scope: true
    ) do |scope|
      domain_ids = scope.where(cached_object_type: 'domain').where(
        ['name ILIKE :domain OR id ILIKE :domain', domain: "%#{domain}%"]
      ).pluck(:id) unless domain.blank?

      projects = scope.where(cached_object_type: 'project')
      projects = projects.where(domain_id: domain_ids) if domain_ids
      unless project.blank?
        projects = projects.where(
          ['name ILIKE :project OR id ILIKE :project', project: "%#{project}%"]
        )
      end
      projects
    end

    render json: { projects: items, has_next: items.has_next, total: items.total }
  end

  def users
    items = ObjectCache.find_objects(
      type: 'user',
      term:  params[:name] || params[:term] || '',
      include_scope: false,
      paginate: false
    ) do |scope|
       unless params[:domain_id].blank?
         scope = scope.where(domain_id: params[:domain_id])
       end
       scope.order(:name)
    end

    items = items.to_a.map do |u|
      {
        id: u.payload['description'], name: u.name, key: u.name,
        uid: u.id, full_name: u.payload['description'],
        email: u.payload['email']
      }
    end

    render json: items
  end

  def projects
    items = ObjectCache.find_objects(
      type: 'project',
      term:  params[:name] || params[:term] || '',
      include_scope: false,
      paginate: false
    ) do |scope|
      unless params[:domain_id].blank?
        scope = scope.where(domain_id: params[:domain_id])
      end
      scope.order(:name)
    end

    items = items.to_a.uniq(&:name).map do |prj|
      { id: prj.id, name: prj.name }
    end

    render json: items
  end
end
