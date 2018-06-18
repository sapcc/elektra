class ObjectCache < ApplicationRecord
  self.table_name = 'object_cache'
  ATTRIBUTE_KEYS = %w[name project_id domain_id cached_object_type search_label].freeze

  belongs_to :project, class_name: 'ObjectCache', primary_key: 'id',
                       foreign_key: 'project_id', optional: true
  belongs_to :domain, class_name: 'ObjectCache', primary_key: 'id',
                      foreign_key: 'domain_id', optional: true

  @cache_objects_mutex = Mutex.new
  @cache_object_mutex = Mutex.new

  TYPE_SEARCH_LABEL_KEYS = {
    'access' => %w[share_id access_to],
    'access_list' => %w[],
    'agent' => %w[description topic host agent_type],
    'availability_zone' => %w[],
    'export_location' => %w[path],
    'floatingip' => %w[description floating_ip_address floating_network_id
                       router_id fixed_ip_address dns_name port_id],
    'hypervisor' => %w[hypervisor_type hypervisor_hostname host_ip],
    'image' => %w[owner user_id image_type instance_uuid],
    'keypair' => %w[user_id],
    'error' => %w[body],
    'listener' => %w[default_pool_id description],
    'member' => %w[protocol_port subnet_id address],
    'message' => %w[resource_id message_level request_id resource_type],
    'network' => %w[dns_domain description subnets],
    'pool' => %w[protocol description],
    'port' => %w[device_owner mac_address description device_id network_id dns_name fixed_ips],
    'rbac_policy' => %w[object_type object_id],
    'recordset' => %w[description zone_id zone_name],
    'router' => %w[description],
    'security_group' => %w[description],
    'security_group_rule' => %w[direction protocol description security_group_id],
    'security_service' => %w[dns_ip description],
    'server' => %w[description hostId user_id addresses],
    'share' => %w[availability_zone share_network_id user_id share_proto],
    'share_network' => %w[neutron_subnet_id neutron_net_id cidr description],
    'snapshot' => %w[volume_id description],
    'subnet' => %w[description network_id gateway_ip cidr],
    'transfer_request' => %w[zone_id zone_name description],
    'user' => %w[description],
    'volume' => %w[displayDescription availabilityZone displayName volumeType links os-vol-tenant-attr:tenant_id],
    'zone' => %w[email description pool_id],

    'catalog' => %w[],
    'cluster' => %w[],
    'domain' => %w[],
    'flavor' => %w[],
    'group' => %w[],
    'healthmonitor' => %w[],
    'l7policy' => %w[],
    'loadbalancer' => %w[],
    'project' => %w[],
    'role' => %w[],
    'share_type' => %w[]
  }

  def self.cache_objects(objects)
    # create a id => object map
    id_object_map = objects.each_with_object({}) { |o, map| map[o['id']] = o }
    # load already cached object ids with payload
    registered_ids = where(id: id_object_map.keys).pluck(:id, :payload)

    # Devide objects in to be created and updated
    objects_to_be_updated = {}
    objects_to_be_created = []

    id_object_map.each do |id, data|
      attributes = object_attributes(data)
      index = registered_ids.index { |id_payload| id_payload[0] == id }

      if index # object is already registered
        if (registered_ids[index][1])
          # merge old payload with the new one
          attributes[:payload] = registered_ids[index][1].merge(attributes[:payload])
        end
        objects_to_be_updated[id] = attributes
      else
        objects_to_be_created << attributes.merge(id: data['id'])
      end
    end

    @cache_objects_mutex.synchronize do
      # update all objects at once
      transaction do
        update(objects_to_be_updated.keys, objects_to_be_updated.values)
      end

      # create all objects at once
      transaction do
        create(objects_to_be_created)
      end
    end
  end

  def self.cache_object(data)
    attributes = object_attributes(data)
    id = data['id']

    @cache_object_mutex.synchronize do
      transaction do
        item = find_by_id(id)
        if item
          attributes[:payload] = item.payload.merge(attributes[:payload])
          item.update(attributes)
        else
          item = create(attributes.merge(id: id))
        end
        item
      end
    end
  end

  # search for objects by a term
  def self.search(args)
    return where(args) if args.is_a?(Hash)
    return nil unless args.is_a?(String)
    where(
      [
        'id ILIKE :term or name ILIKE :term or project_id ILIKE :term or ' \
        'domain_id ILIKE :term or search_label ILIKE :term',
        term: "%#{args}%"
      ]
    )
  end

  # Advanced search method with block. If a block is given then it is
  # called by passing scope into it.
  # options:
  # => :term a search string
  # => :type a string which identifies the type of objects
  # => :include_scope a boolean
  # => :paginate is a hash of :page, :per_page
  # Example: find_objects(
  #            term: 'D0', type: 'user', include_scope: true,
  #            paginate: {page: 1, per_page: 30}
  #          ) { |scope| scope.where(name: 'Mustermann') }
  # Returns an Array of found objects. If paginate options is provided then
  # it adds a "total" and "has_next" methods to it.
  def self.find_objects(options = {})
    scope = ObjectCache.all
    # reduce scope to objects with the given type
    unless options[:type].blank?
      scope = scope.where(cached_object_type: options[:type])
    end

    # search objects by term
    scope = scope.search(options[:term]) unless options[:term].blank?
    # include associations domain and project (two more queries)
    scope = scope.includes(:domain, project: :domain) if options[:include_scope]
    scope = yield scope if block_given?

    if options[:paginate]
      page = (options[:paginate][:page] || 1).to_i
      per_page = (options[:paginate][:per_page] || 30).to_i

      objects = scope.limit(per_page + 1).offset((page - 1) * per_page)
      total = objects.except(:offset, :limit, :order).count
      has_next = objects.length > per_page
      objects = objects.to_a
      objects.pop if has_next

      extend_object_payload_with_scope(objects) if options[:include_scope]
      objects.define_singleton_method(:total) { total }
      objects.define_singleton_method(:has_next) { has_next }
    else
      objects = scope.respond_to?(:to_a) ? scope.to_a : [scope]
      extend_object_payload_with_scope(objects) if options[:include_scope]
    end
    objects
  end

  def self.object_attributes(data)
    data['project_id'] = data['project_id'] || data['tenant_id']
    data['search_label'] = search_label(data)
    data.select do |k, v|
      ATTRIBUTE_KEYS.include?(k) && !v.blank?
    end.merge(payload: data)
  end

  def self.extend_object_payload_with_scope(objects)
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

  # generate a search label for object
  def self.search_label(data)
    object_type = data['cached_object_type'].try(:downcase)
    keys = TYPE_SEARCH_LABEL_KEYS[object_type] if object_type

    return '' if keys.nil? || keys.empty?

    keys.each_with_object([]) do |key, search_string|
      search_string << "#{key}: #{data[key]}" unless data[key].blank?
    end.join(' ')
  end

end
