# frozen_string_literal: true

class CacheController < ::ApplicationController
  include Services
  include ApiLookup

  class NotFound < StandardError; end

  before_action :load_user_session

  def index
    return if login_required?

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
    return if login_required?
    data = begin
             api_search(services, params[:type], params[:term])
           rescue StandardError => e
             p e
             { items: [] }
           end
    render json: data
  end

  def show
    return if login_required?

    objects = ObjectCache.find_objects(include_scope: true) do |scope|
      where_current_token_scope(scope).where(id: params[:id])
    end

    render json: objects.first
  end

  def types
    return if login_required?

    cached_types = ::ObjectCache.distinct.pluck(:cached_object_type)
                                .delete_if(&:blank?)

    render json: (cached_types + ObjectCache::TYPE_SEARCH_LABEL_KEYS.keys).uniq
  end

  def domain_projects
    return if login_required?

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
    return if login_required?

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
    return if login_required?

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
    return scope if cloud_admin?

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

  def load_user_session
    # check if user is authenticated
    @auth_session = AuthSession.load_user_from_session(
      self, domain: params[:domain_id], project: params[:project_id]
    )
    @current_user = @auth_session.user if logged_in?
  end

  def render_authentication_error
    render json: { error: 'You are not authorized!' }, status: 401
  end

  def login_required?
    return false if @current_user
    render_authentication_error
    true
  end

  def cloud_admin?
    return false unless @current_user
    return false unless @current_user.project_domain_name ==
                        Rails.application.config.cloud_admin_domain
    @current_user.project_name == Rails.configuration.cloud_admin_project
  end
end
