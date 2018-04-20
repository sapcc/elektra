class ObjectCache < ApplicationRecord
  self.table_name = 'object_cache'
  ATTRIBUTE_KEYS = %w[name project_id domain_id cached_object_type]

  def self.cache_objects(objects)
    # create a id => object map
    id_object_map = objects.each_with_object({}) { |o, map| map[o['id']] = o }
    # load already cached objects
    registered_ids = where(id: id_object_map.keys).pluck(:id)

    # Devide objects in to be created and updated
    objects_to_be_updated = {}
    objects_to_be_created = []

    id_object_map.each do |id, data|
      attributes = object_attributes(data)

      if registered_ids.include?(id)
        objects_to_be_updated[id] = attributes
      else
        objects_to_be_created << attributes.merge(id: data['id'])
      end
    end

    # update all objects at once
    transaction do
      update(objects_to_be_updated.keys, objects_to_be_updated.values)
    end

    # create all objects at once
    transaction do
      create(objects_to_be_created)
    end


    #update(objects_to_be_updated.keys, objects_to_be_updated.values)
    #
    # create(objects_to_be_created)
  end

  def self.cache_object(data)
    attributes = object_attributes(data)
    id = data['id']

    transaction do
      item = find_by_id(id)
      if item
        item.update(attributes)
      else
        item = create(attributes.merge(id: id))
      end
      item
    end
  end

  def self.search(args)
    return where(args) if args.is_a?(Hash)
    return nil unless args.is_a?(String)
    where(
      [
        'id ILIKE :term or name ILIKE :term or project_id ILIKE :term or ' \
        'domain_id ILIKE :term',
        term: "%#{args}%"
      ]
    )
  end

  def self.object_attributes(data)
    data['project_id'] = data['project_id'] || data['tenant_id']
    data.select do |k, v|
      ATTRIBUTE_KEYS.include?(k) && !v.blank?
    end.merge(payload: data)
  end
end
