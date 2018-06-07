# frozen_string_literal: true

class CacheController < ::ScopeController
  include ApiLookup

  class NotFound < StandardError; end

  authentication_required domain: ->(c) { c.instance_variable_get(:@scoped_domain_id) },
                          domain_name: ->(c) { c.instance_variable_get(:@scoped_domain_name) },
                          project: ->(c) { c.instance_variable_get(:@scoped_project_id) },
                          rescope: true

  def index
    page = (params[:page] || 1).to_i

    items = ObjectCache.find_objects(
      type: params[:type], term: params[:term], include_scope: true,
      paginate: { page: page, per_page: 30 }
    ) { |scope| where_current_token_scope(scope).order(:name) }

    render json: { items: items, total: items.total, has_next: items.has_next }
  rescue StandardError
    render json: { items: [] }
  end

  def live_search
    data = begin
             api_search(services, params[:type], params[:term])
           rescue StandardError => e
             p e
             { items: [] }
           end
    render json: data
  end

  def show
    objects = ObjectCache.find_objects(include_scope: true) do |scope|
      where_current_token_scope(scope).where(id: params[:id])
    end

    render json: objects.first
  end

  def types
    cached_types = ::ObjectCache.distinct.pluck(:cached_object_type)
                                .delete_if(&:blank?)

    render json: (cached_types + ObjectCache::TYPE_SEARCH_LABEL_KEYS.keys).uniq
  end

  def domain_projects
    unless cloud_admin?
      render json: { projects: [], has_next: false, total: 0 }
      return
    end

    page = (params[:page] || 1).to_i

    domain = params[:domain]
    project = params[:project]

    domain_ids = ObjectCache.where(cached_object_type: 'domain').where(
      [
        'object_cache.name ILIKE :domain OR object_cache.id ILIKE :domain',
        domain: "%#{domain}%"
      ]
    ).pluck(:id) unless domain.blank?


    items = ObjectCache.find_objects(
      paginate: { page: page, per_page: 30 },
      type: 'project',
      include_scope: true
    ) do |scope|
      projects = domain_ids.nil? ? scope : scope.where(domain_id: domain_ids)
      unless project.blank?
        projects = projects.where(
          [
            'object_cache.name ILIKE :project OR object_cache.id ILIKE :project',
            project: "%#{project}%"
          ]
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
      if cloud_admin?
        scope.where(domain_id: params[:domain]).order(:name)
      else
        where_current_token_scope(scope).order(:name)
      end
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
      if cloud_admin?
        scope.where(domain_id: params[:domain]).order(:name)
      else
        where_current_token_scope(scope).order(:name)
      end
    end

    items = items.to_a.uniq(&:name).map do |prj|
      { id: prj.id, name: prj.name }
    end

    render json: items
  end

  protected

  def where_current_token_scope(scope)
    return scope if current_user.is_allowed?('cloud_admin')

    project_id = @current_user.project_id
    domain_id = @current_user.project_domain_id ||
                      @current_user.domain_id ||
                      @current_user.user_domain_id

    sql = []
    sql << 'project_id = :project_id' if project_id
    sql << 'domain_id = :domain_id' if domain_id

    scope.where(
      [sql.join(' OR '), project_id: project_id, domain_id: domain_id]
    )
  end
end
