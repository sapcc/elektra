module ServiceLayer
  class ObjectStorageService < Core::ServiceLayer::Service
    include ObjectStorageServices::Account
    include ObjectStorageServices::StorageObject
    include ObjectStorageServices::Container

    def available?(_action_name_sym = nil)
      elektron.service?("object-store")
    end

    def elektron_object_storage
      @elektron_object_storage ||= elektron.service("object-store")
    end

    def list_capabilities
      elektron_object_storage
        .get("info", path_prefix: "/")
        .map_to("body") { |data| ObjectStorage::Capabilities.new(self, data) }
    end

    protected

    # Rename keys in `data` using the `attribute_map` and delete unknown keys.
    def map_attribute_names(data, attribute_map)
      data
        .transform_keys { |k| attribute_map.fetch(k, nil) }
        .reject { |key, _| key.nil? }
    end

    def extract_metadata_data(headers, prefix)
      result = {}
      headers.each do |key, value|
        result[key.sub(prefix, "")] = value if key.start_with?(prefix)
      end
      result
    end

    def extract_header_data(response)
      header_data = {}
      response.header.each_header { |key, value| header_data[key] = value }
      header_data
    end

    def stringify_header_values(header_attrs)
      header_attrs.deep_merge!(header_attrs) { |_, _, v| v.to_s }
      header_attrs.stringify_keys!
    end

    # remove duplicate slashes that might have been created by naive path
    def sanitize_path(path)
      # joining (e.g. `foo + "/" + bar`)
      path = path.gsub(%r{^/+}, "/")

      # remove leading and trailing slash
      path.sub(%r{^/}, "").sub(%r{/$}, "")
    end

    def public_url(container_name, object_path = nil)
      return nil if container_name.nil?
      url = "#{elektron_object_storage.endpoint_url}/#{escape(container_name)}"
      if object_path.nil?
        # path to container listing needs a trailing slash to work in a browser
        url << "/"
      else
        url << "/#{escape(object_path)}"
      end
      url
    end

    def escapeURI(uri)
      CGI.escapeURIComponent(uri)
    end

    # https://github.com/fog/fog-openstack/blob/bd69c6f3a80bb4a984d6fc67971a496cc923ac98/lib/fog/openstack.rb#L588
    def escape(str, extra_exclude_chars = "")
      str.gsub(%r{([^a-zA-Z0-9_./#{extra_exclude_chars}-]+)}) do
        "%" +
          Regexp
            .last_match(1)
            .unpack("H2" * Regexp.last_match(1).bytesize)
            .join("%")
            .upcase
      end
    end
  end
end
