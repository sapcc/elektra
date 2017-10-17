module ServiceLayerNg
  class ObjectStorageService < Core::ServiceLayerNg::Service


    CONTAINERS_ATTRMAP = {
      # name in API response => name in our model (that is part of this class's interface)
      'bytes' => 'bytes_used',
      'count' => 'object_count',
      'name'  => 'name',
    }
    CONTAINER_ATTRMAP = {
      # name in API => name in our model
      'x-container-object-count'      => 'object_count',
      'x-container-bytes-used'        => 'bytes_used',
      'x-container-meta-quota-bytes'  => 'bytes_quota',
      'x-container-meta-quota-count'  => 'object_count_quota',
      'x-container-read'              => 'read_acl',
      'x-container-write'             => 'write_acl',
      'x-versions-location'           => 'versions_location',
      'x-container-meta-web-index'    => 'web_index',
      'x-container-meta-web-listings' => 'web_file_listing',
    }
    CONTAINER_WRITE_ATTRMAP = {
      # name in our model => name in create/update API request
      'bytes_quota'        => 'x-container-meta-quota-bytes',
      'object_count_quota' => 'x-container-meta-quota-count',
      'read_acl'           => 'x-container-read',
      'write_acl'          => 'x-container-write',
      'versions_location'  => 'x-versions-location',
      'web_index'          => 'x-container-meta-web-index',
      'web_file_listing'   => 'x-container-meta-web-listings',
    }

    def available?(_action_name_sym = nil)
      api.catalog_include_service?('object-store', region)
    end
    
    def capabilities
      Rails.logger.debug  "[object_storage-service] -> capabilities -> GET /info"
      response = api.object_storage.list_activated_capabilities
       map_to(ObjectStorage::Capabilities, response.body)
    end
    
    def containers
      Rails.logger.debug  "[object_storage-service] -> containers -> GET /"
      list = api.object_storage.show_account_details_and_list_containers.body
      list.map! do |c|
        container = map_attribute_names(c, CONTAINERS_ATTRMAP)
        container['id'] = container['name'] # name also serves as id() for Core::ServiceLayer::Model
        container
      end
      map_to(ObjectStorage::ContainerNg, list)
    end
    
    def find_container(container_name)
      Rails.logger.debug  "[object_storage-service] -> find_container -> GET /"
      response = api.object_storage.show_container_details_and_list_objects(container_name)
      map_to(ObjectStorage::ContainerNg, response.body)
    end
    
    def container_metadata(container_name)
      Rails.logger.debug  "[object_storage-service] -> container_metadata -> HEAD /v1/{account}/{container}"
      response = api.object_storage.show_container_metadata(container_name)
      data = build_header_data(response,container_name)
      map_to(ObjectStorage::ContainerNg, data)
    end

   private

    # Rename keys in `data` using the `attribute_map` and delete unknown keys.
    def map_attribute_names(data, attribute_map)
      data.transform_keys { |k| attribute_map.fetch(k, nil) }.reject { |key,_| key.nil? }
    end

    def extract_metadata_tags(headers, prefix)
      result = {}
      headers.each do |key,value|
        if key.start_with?(prefix)
          result[key.sub(prefix, '')] = value
        end
      end
      return result
    end
    
    def build_header_data(response,container_name = nil)
      headers = {}
      response.header.each_header{|key,value| headers[key] = value}
      header_hash = map_attribute_names(headers, CONTAINER_ATTRMAP)
      
      # enrich data with additional information
      header_hash['id'] = header_hash['name'] = container_name
      #header_hash['public_url'] = fog_public_url(container_name)
      header_hash['web_file_listing'] = header_hash['web_file_listing'] == 'true' # convert to Boolean
      header_hash['metadata']   = extract_metadata_tags(headers, 'x-container-meta-').reject do |key, value|
        # skip metadata fields that are recognized by us
        CONTAINER_ATTRMAP.has_key?('x-container-meta-' + key)
      end
      
      header_hash
    end
  end
end