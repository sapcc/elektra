module ServiceLayerNg
  class ObjectStorageService < Core::ServiceLayerNg::Service
    include ObjectStorageServices::Account
    include ObjectStorageServices::StorageObject
    include ObjectStorageServices::Container

    def available?(_action_name_sym = nil)
      elektron.service?('object-store')
    end

    def elektron_object_storage
      @elektron_object_storage ||= elektron.service('object-store')
    end

    def list_capabilities
      elektron_object_storage.get('/info').map_to('body') do |data|
        ObjectStorage::Capabilities.new(self, data)
      end
    end

    private

    # Rename keys in `data` using the `attribute_map` and delete unknown keys.
    def map_attribute_names(data, attribute_map)
      data.transform_keys { |k| attribute_map.fetch(k, nil) }.reject { |key, _| key.nil? }
    end

    def extract_metadata_data(headers, prefix)
      result = {}
      headers.each do |key, value|
        result[key.sub(prefix, '')] = value if key.start_with?(prefix)
      end
      result
    end

    def extract_header_data(response)
      header_data = {}
      response.header.each_header { |key, value| header_data[key] = value }
      header_data
    end

    def extract_container_header_data(response, container_name = nil)
      header_hash = map_attribute_names(extract_header_data(response), CONTAINER_ATTRMAP)
      # enrich data with additional information
      header_hash['id']               = header_hash['name'] = container_name
      header_hash['public_url']       = public_url(container_name)
      header_hash['web_file_listing'] = header_hash['web_file_listing'] == 'true' # convert to Boolean
      header_hash['metadata']         = extract_metadata_data(extract_header_data(response), 'x-container-meta-').reject do |key, _value|
        # skip metadata fields that are recognized by us
        CONTAINER_ATTRMAP.key?('x-container-meta-' + key)
      end

      header_hash
    end

    def extract_object_header_data(response, container_name = nil, object_path = nil)
      header_hash = map_attribute_names(extract_header_data(response), OBJECT_ATTRMAP)
      header_hash['id']               = header_hash['path'] = object_path
      header_hash['container_name']   = container_name
      header_hash['public_url']       = public_url(container_name, object_path)
      header_hash['last_modified_at'] = DateTime.httpdate(header_hash['last_modified_at']) # parse date
      header_hash['created_at']       = DateTime.strptime(header_hash['created_at'], '%s') # parse UNIX timestamp
      header_hash['expires_at']       = DateTime.strptime(header_hash['expires_at'], '%s') if header_hash.key?('expires_at') # optional!
      header_hash['metadata']         = extract_metadata_data(extract_header_data(response), 'x-object-meta-')
      header_hash
    end

    def build_custom_request_header(header_attrs)
      # stringify keys and values
      # https://stackoverflow.com/questions/34595141/process-nested-hash-to-convert-all-values-to-strings
      header_attrs.deep_merge!(header_attrs) { |_, _, v| v.to_s }
      header_attrs.stringify_keys!
      # create custom header
      Misty::HTTP::Header.new(header_attrs)
    end

    # remove duplicate slashes that might have been created by naive path
    def sanitize_path(path)
      # joining (e.g. `foo + "/" + bar`)
      path = path.gsub(/^\/+/, '/')

      # remove leading and trailing slash
      path.sub(/^\//, '').sub(/\/$/, '')
    end

    def public_url(container_name, object_path = nil)
      return nil if container_name.nil?
      url = "#{api.object_storage.uri}/#{escape(container_name)}"
      if object_path.nil?
        # path to container listing needs a trailing slash to work in a browser
        url << '/'
      else
        url << "/#{escape(object_path)}"
      end
      url
    end

    # https://github.com/fog/fog-openstack/blob/bd69c6f3a80bb4a984d6fc67971a496cc923ac98/lib/fog/openstack.rb#L588
    def escape(str, extra_exclude_chars = '')
      str.gsub(/([^a-zA-Z0-9_.\/#{extra_exclude_chars}-]+)/) do
        '%' + Regexp.last_match(1).unpack('H2' * Regexp.last_match(1).bytesize).join('%').upcase
      end
    end
  end
end
