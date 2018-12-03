# frozen_string_literal: true

require 'csv'

class CacheController < ::ScopeController
  include ApiLookup

  RELATED_OBJECTS_KEYS = {
    'port' => %w[network_id device_id security_groups],
    'floatingip' => %w[router_id floating_network_id port_id],
    'router' => %w[network_id external_gateway_info.network_id external_gateway_info.external_fixed_ips.subnet_id subnet_id port_id],
    'subnet' => %w[network_id],
    'server' => %w[image.id]
  }.freeze

  class NotFound < StandardError; end
  authentication_required domain: ->(c) { c.instance_variable_get(:@scoped_domain_id) },
                          domain_name: ->(c) { c.instance_variable_get(:@scoped_domain_name) },
                          project: ->(c) { c.instance_variable_get(:@scoped_project_id) },
                          rescope: true#, except: %i[related_objects]

  before_action do
    @enforce_scope = if params[:enforce_scope].nil? || params[:enforce_scope] =~ (/(false|f|no|n|0)$/i)
                       false
                     elsif params[:enforce_scope].empty? || params[:enforce_scope] =~ (/(true|t|yes|y|1)$/i)
                       true
                     end
  end

  def index
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 30).to_i

    items = ObjectCache.find_objects(
      type: params[:type], term: params[:term], include_scope: true,
      paginate: { page: page, per_page: per_page }
    ) do |sql|
      where_current_token_scope(sql).order(:name)
    end

    render json: { items: items, total: items.total, has_next: items.has_next }
  rescue StandardError
    render json: { items: [] }
  end

  def csv
    items = ObjectCache.find_objects(
      type: params[:type], term: params[:term], include_scope: true,
      paginate: false
    ) do |sql|
      where_current_token_scope(sql).order(:name)
    end

    csv_string = CSV.generate do |csv|
      csv << ['Type', 'Name', 'ID', 'Details', 'Domain Name', 'Domain ID', '(Parent) Project Name', 'Project Name']
      items.each do |item|
        if item.payload['scope']
          csv << [
            item.cached_object_type, item.name, item.id, item.search_label,
            item.payload['scope']['domain_name'], item.payload['scope']['domain_id'],
            item.payload['scope']['project_name'], item.payload['scope']['project_id']
          ]
        end
      end
    end

    filename = []
    filename << params[:type].to_s unless params[:type].blank?
    filename << params[:term].to_s unless params[:term].blank?
    filename = filename.join('_')
    filename = 'all' if filename.blank?

    send_data csv_string,  filename: "#{filename}.csv"
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
    unless current_user.is_allowed?('cloud_admin')
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
    retries ||= 0

    items = ObjectCache.find_objects(
      type: 'user',
      term:  params[:name] || params[:term] || '',
      include_scope: false,
      paginate: false
    ) do |scope|
      # allow all users from scoped domain.
      # this action is called by autocomplete widget.
      #if current_user.is_allowed?('cloud_admin')
        scope.where(domain_id: params[:domain]).order(:name)
      #else
      #  where_current_token_scope(scope).order(:name)
      #end
    end

    raise NotFound if (items.nil? || items.empty?) && retries < 1

    items = items.to_a.map do |u|
      {
        id: u.payload['description'], name: u.name, key: u.name,
        uid: u.id, full_name: u.payload['description'],
        email: u.payload['email']
      }
    end

    render json: items
  rescue NotFound
    retries += 1
    # search live against API and then retry
    service_user.identity.users(domain_id: params[:domain])
    retry
  end

  def groups
    items = ObjectCache.find_objects(
      type: 'group',
      term:  params[:name] || params[:term] || '',
      include_scope: false,
      paginate: false
    ) do |scope|
      if current_user.is_allowed?('cloud_admin')
        scope.where(domain_id: params[:domain]).order(:name)
      else
        where_current_token_scope(scope).order(:name)
      end
    end


    items = items.to_a.map do |g|
      { id: g.id, name: g.name }
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
      if current_user.is_allowed?('cloud_admin')
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

  def related_object_values(key, payload)
    if payload.is_a?(Array)
      return payload.collect { |data| related_object_values(key, data) }
    end

    if key.include?('.')
      nested_keys = key.split('.')

      data = payload
      nested_keys.each do |nested_key|
        data = related_object_values(nested_key, data) if data
      end

      return data
    end

    payload[key]
  end

  def related_objects
    unless current_user.is_allowed?('cloud_admin')
      render json: []
      return
    end

    sql = ['payload::text ILIKE ?', "%#{params[:id]}%"]

    cached_object = ObjectCache.where(id: params[:id]).first

    if cached_object
      if cached_object.project_id
        sql[0] += ' OR id = ?'
        sql << cached_object.project_id
      end

      keys = RELATED_OBJECTS_KEYS[cached_object.cached_object_type] || []
      values = keys.collect do |key|
        related_object_values(key, cached_object.payload)
      end.flatten.uniq

      if values && values.length.positive?
        sql[0] += " OR id IN (?)"
        sql << values
      end
    end

    render json: ObjectCache
      .where.not(cached_object_type: %w[error flavor], id: params[:id])
      .where(sql)
  end

  protected

  def where_current_token_scope(scope, enforce_scope = @enforce_scope)
    return scope if !enforce_scope && current_user.is_allowed?('cloud_admin_or_support')

    if current_user.project_id && params[:type] == 'project'
      scope = scope.where(id: current_user.project_id)
    end

    project_id = current_user.project_id
    domain_id = (current_user.project_domain_id || current_user.domain_id)

    if project_id
      scope.where(["project_id = :project_id OR id = :project_id", project_id: project_id])
    elsif domain_id
      project_ids = ObjectCache.where(
        cached_object_type: 'project', domain_id: domain_id
      ).pluck(:id)

      scope.where(
        ["domain_id = :domain_id OR id = :domain_id OR project_id IN (:project_ids)",
        domain_id: domain_id,
        project_ids: project_ids]
      )
    else
      scope.where('domain_id IS NULL OR project_id IS NULL')
    end
  end
end
