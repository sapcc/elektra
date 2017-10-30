module ServiceLayerNg
  class ObjectStorageService < Core::ServiceLayerNg::Service

   # TODO:
   # 2. move object_ng to object
   # 3. bulk delete
   # 4- check old @driver calls in container and object and maybe port it back from controller to model
   
   def available?(_action_name_sym = nil)
     api.catalog_include_service?('object-store', region)
   end
    
   def list_capabilities
     Rails.logger.debug  "[object-storage-service] -> capabilities -> GET /info"
     response = api.object_storage.list_activated_capabilities
      map_to(ObjectStorage::Capabilities, response.body)
   end
 
   # ACCOUNT #
   
   ACCOUNT_ATTRMAP = {
     'x-account-container-count'    => 'container_count',
     'x-account-object-count'       => 'object_count',
     'x-account-meta-quota-bytes'   => 'bytes_quota',
     'x-container-meta-quota-count' => 'object_count_quota',
     'x-account-bytes-used'         => 'bytes_used'
   }
   
   def account
     Rails.logger.debug  "[object-storage-service] -> account -> HEAD /"
     response = nil
     begin
       response = api.object_storage.show_account_metadata()
     rescue Exception => e
       # 200 success list containers
       # 202 success but no content found
       # 404 account is not existing
       if e.code == 404
         return nil
       end
     end
     account_data = map_attribute_names(extract_header_data(response), ACCOUNT_ATTRMAP)
     map_to(ObjectStorage::Account,account_data)
   end
   
   def create_account
     Rails.logger.debug  "[object-storage-service] -> create_account -> POST /"
     api.object_storage.create_update_or_delete_account_metadata
   end

   # CONTAINER #

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

   
    def containers
      Rails.logger.debug  "[object-storage-service] -> containers -> GET /"
      list = api.object_storage.show_account_details_and_list_containers.body
      list.map! do |c|
        container = map_attribute_names(c, CONTAINERS_ATTRMAP)
        container['id'] = container['name'] # name also serves as id() for Core::ServiceLayer::Model
        container
      end
      map_to(ObjectStorage::Container, list)
    end
    
    def container_details_and_list_objects(container_name)
      Rails.logger.debug  "[object-storage-service] -> find_container -> GET /"
      response = api.object_storage.show_container_details_and_list_objects(container_name)
      map_to(ObjectStorage::Container, response.body)
    end
    
    def container_metadata(container_name)
      Rails.logger.debug  "[object-storage-service] -> container_metadata -> HEAD #{container_name}"
      response = api.object_storage.show_container_metadata(container_name)
      data = extract_container_header_data(response,container_name)
      map_to(ObjectStorage::Container, data)
    end

    def new_container(attributes={})
      Rails.logger.debug  "[object-storage-service] -> new_container"
      map_to(ObjectStorage::Container, attributes)
    end

    def empty(container_name)
      Rails.logger.debug  "[object-storage-service] -> empty -> #{container_name}"
      targets = list_objects(container_name).map do |obj|
        { container: container_name, object: obj['path'] }
      end
      bulk_delete(targets)
    end
    
    def empty?(container_name)
      Rails.logger.debug  "[object-storage-service] -> empty? -> #{container_name}"
      list_objects(container_name, limit: 1).count == 0
    end 

    def create_container(params = {})
      Rails.logger.debug  "[object-storage-service] -> create_container"
      Rails.logger.debug  "[object-storage-service] -> parameter:#{params}"
      name = params.delete(:name)
      api.object_storage.create_container(name, Misty.to_json(params)).body
    end
    
    def delete_container(container_name)
      Rails.logger.debug  "[object-storage-service] -> delete_container -> #{container_name}"
      api.object_storage.delete_container(container_name).body
    end

    def update_container(container_name, params={})
      # update container properties and access control
      Rails.logger.debug  "[object-storage-service] -> update_container -> #{container_name}"
      Rails.logger.debug  "[object-storage-service] -> parameter:#{params}"

      header_attrs = map_attribute_names(params, CONTAINER_WRITE_ATTRMAP)

      # convert difference between old and new metadata into a set of changes
      old_metadata = params['original_metadata']
      new_metadata = params['metadata']
      if old_metadata.nil? && !new_metadata.nil?
        raise InputError, 'cannot update metadata without knowing the current metadata'
      end
      (old_metadata || {}).each do |key, value|
        unless new_metadata.has_key?(key)
          header_attrs["x-remove-container-meta-#{key}"] = "1"
        end
      end
      (new_metadata || {}).each do |key, value|
        if old_metadata[key] != value
          header_attrs["x-container-meta-#{key}"] = value
        end
      end
      
      # update metadata
      api.object_storage.create_update_or_delete_container_metadata(container_name,build_custom_request_header(header_attrs))
      # return nothing
      nil
    end

    # OBJECTS # 

    OBJECTS_ATTRMAP = {
      # name in API response => name in our model (that is part of this class's interface)
      'bytes'         => 'size_bytes',
      'content_type'  => 'content_type',
      'hash'          => 'md5_hash',
      'last_modified' => 'last_modified_at',
      'name'          => 'path',
      'subdir'        => 'path', # for subdirectories, only this single attribute is given
    }
    OBJECT_ATTRMAP = {
      'content-length' => 'size_bytes',
      'content-type'   => 'content_type',
      'etag'           => 'md5_hash',
      'last-modified'  => 'last_modified_at',
      'x-timestamp'    => 'created_at',
      'x-delete-at'    => 'expires_at',
    }
    OBJECT_WRITE_ATTRMAP = {
      # name in our model => name in create/update API request
      'content_type'   => 'Content-Type',
      # 'expires_at'     => 'X-Delete-At', # this is special-cased in update_object()
    }

    def object_metadata(container_name,object_path)
      Rails.logger.debug  "[object-storage-service] -> find_object -> #{container_name}, #{object_path}"
      return nil if container_name.blank? or object_path.blank?
      response = api.object_storage.show_object_metadata(container_name, object_path)
      data = extract_object_header_data(response,container_name,object_path)
      map_to(ObjectStorage::ObjectNg, data)
    end

    def object_content(container_name, object_path)
      Rails.logger.debug  "[object-storage-service] -> object_content_and_metadata -> #{container_name}, #{object_path}"
      api.object_storage.get_object_content_and_metadata(container_name,object_path).body
    end

    def list_objects(container_name, options={})
      Rails.logger.debug  "[object-storage-service] -> list_objects -> #{container_name}"
      Rails.logger.debug  "[object-storage-service] -> list_objects -> Options: #{options}"
      
      # prevent prefix and delimiter with slash, if this happens an empty list is returned
      options[:prefix] = "" if options[:prefix] == "/" and options[:delimiter] == "/" 
      
      list = api.object_storage.show_container_details_and_list_objects(container_name, options).body
      list.map! do |o|
        object = map_attribute_names(o, OBJECTS_ATTRMAP)
        object['id'] = object['path'] # path also serves as id() for Core::ServiceLayer::Model
        object['container_name'] = container_name
        if object.has_key?('last_modified_at')
          object['last_modified_at'] = DateTime.iso8601(object['last_modified_at']) # parse date
        end
        object
      end
    end
    
    def list_objects_at_path(container_name, object_path, filter={})
      Rails.logger.debug  "[object-storage-service] -> list_objects_at_path -> #{container_name}, #{object_path}, #{filter}"
      object_path += '/' if !object_path.end_with?('/') && !object_path.empty?
      result = list_objects(container_name, filter.merge(prefix: object_path, delimiter: '/'))
      # if there is a pseudo-folder at `object_path`, it will be in the result, too;
      # filter this out since we only want stuff below `object_path`
      objects = result.reject { |obj| obj['id'] == object_path }
      map_to(ObjectStorage::Object, objects)
    end

    def list_objects_below_path(container_name, object_path, filter={})
      Rails.logger.debug  "[object-storage-service] -> list_objects_below_path -> #{container_name}, #{object_path}, #{filter}"
      path += '/' if !object_path.end_with?('/') && !object_path.empty?
      objects =  list_objects(container_name, filter.merge(prefix: object_path))
      map_to(ObjectStorage::Object, objects)
    end

    def copy_object(source_container_name, source_path, target_container_name, target_path, options={})
      Rails.logger.debug  "[object-storage-service] -> copy_object -> #{source_container_name}/#{source_path} to #{target_container_name}/#{target_path}"
      Rails.logger.debug  "[object-storage-service] -> copy_object -> Options: #{options}"
      header_attrs = {
          'Destination' => "/#{target_container_name}/#{target_path}"
      }.merge(options)
      api.object_storage.copy_object(source_container_name,source_path,build_custom_request_header(header_attrs))
    end
    
    def move_object(source_container_name, source_path, target_container_name, target_path, options={})
      Rails.logger.debug  "[object-storage-service] -> move_object -> #{source_container_name}/#{source_path} to #{target_container_name}/#{target_path}"
      Rails.logger.debug  "[object-storage-service] -> move_object -> Options: #{options}"
      copy_object(source_container_name, source_path, target_container_name, target_path, options.merge(with_metadata: true))
      delete_object(source_container_name, source_path)
    end

    def bulk_delete(targets)
      Rails.logger.debug  "[object-storage-service] -> bulk_delete"
      Rails.logger.debug  "[object-storage-service] -> targets: #{targets}"

#      TODO:
#      https://github.com/fog/fog-openstack/blob/master/lib/fog/storage/openstack/requests/delete_multiple_objects.rb
#      DELETE with body, that is sadly not possible yet in misty
#      https://github.com/flystack/misty/blob/master/lib/misty/http/method_builder.rb#L25
#      capabilities = list_capabilities
#      if capabilities.attributes.has_key?('bulk_delete')
#        # assemble the request body containing the paths to all targets
#        body = ""
#        targets.each do |target|
#          unless target.has_key?(:container)
#            raise ArgumentError, "malformed target #{target.inspect}"
#          end
#          body += target[:container]
#          if target.has_key?(:object)
#            body += "/" + target[:object]
#          end
#          body += "\n"
#        end
#
#        # TODO: the bulk delete request is missing in Fog
#        @fog.send(:request, {
#          expects: 200,
#          method:  'DELETE',
#          path:    '',
#          query:   { 'bulk-delete' => 1 },
#          headers: { 'Content-Type' => 'text/plain' },
#          body:    body,
#        })
#      else
        targets.each do |target|
          unless target.has_key?(:container)
            raise ArgumentError, "malformed target #{target.inspect}"
          end

          if target.has_key?(:object)
            delete_object(target[:container],target[:object])
          else
            delete_container(target[:container])
          end
        end
#      end
    end
    
    def create_object(container_name, object_path, contents)
      object_path = sanitize_path(object_path)
      Rails.logger.debug  "[object-storage-service] -> create_object -> #{container_name}, #{object_path}"

      # content type "application/directory" is needed on pseudo-dirs for
      # staticweb container listing to work correctly
      header_attrs = {}
      header_attrs['Content-Type'] = 'application/directory' if object_path.end_with?('/')
      header_attrs['Content-Type'] = ''
      # Note: `contents` is an IO object to allow for easy future expansion to
      # more clever upload strategies (e.g. SLO); for now, we just send
      # everything at once

      api.object_storage.create_or_replace_object(container_name, object_path, contents.read, build_custom_request_header(header_attrs))
    end

    def delete_object(container_name,object_path)
      Rails.logger.debug  "[object-storage-service] -> delete_object -> #{container_name}, #{object_path}"
      api.object_storage.delete_object(container_name,object_path)
    end
    
    def update_object_ng(object_path, params)
      container_name = params[:container_name]
      Rails.logger.debug  "[object-storage-service] -> update_object -> #{container_name}/#{object_path}"
      Rails.logger.debug  "[object-storage-service] -> update_object -> Params: #{params}"

      header_attrs = map_attribute_names(params, OBJECT_WRITE_ATTRMAP)

      unless params['expires_at'].nil?
        header_attrs['x-delete-at'] = params['expires_at'].getutc.strftime('%s')
      end

      (params['metadata'] || {}).each do |key, value|
        header_attrs["x-object-meta-#{key}"] = value
      end
      
      api.object_storage.create_or_update_object_metadata(container_name,object_path,build_custom_request_header(header_attrs))
      
      nil
    end

    def create_folder(container_name, object_path)
      Rails.logger.debug  "[object-storage-service] -> create_folder -> #{container_name}, #{object_path}"
      # a pseudo-folder is created by writing an empty object at its path, with
      # a "/" suffix to indicate the folder-ness
      api.object_storage.create_or_replace_object(container_name, sanitize_path(object_path) + '/')
    end
    
    def delete_folder(container_name, object_path)
      Rails.logger.debug  "[object-storage-service] -> delete_folder -> #{container_name}, #{object_path}"
      targets = list_objects_below_path(container_name, sanitize_path(object_path) + '/').map do |obj|
        { container: container_name, object: obj.path }
      end
      bulk_delete(targets)
    end

   private

    # Rename keys in `data` using the `attribute_map` and delete unknown keys.
    def map_attribute_names(data, attribute_map)
      data.transform_keys { |k| attribute_map.fetch(k, nil) }.reject { |key,_| key.nil? }
    end

    def extract_metadata_data(headers, prefix)
      result = {}
      headers.each do |key,value|
        if key.start_with?(prefix)
          result[key.sub(prefix, '')] = value
        end
      end
      return result
    end
    
    def extract_header_data(response)
      header_data = {}
      response.header.each_header{|key,value| header_data[key] = value}
      header_data
    end
    
    def extract_container_header_data(response,container_name = nil)
      header_hash = map_attribute_names(extract_header_data(response), CONTAINER_ATTRMAP)
      # enrich data with additional information
      header_hash['id']               = header_hash['name'] = container_name
      header_hash['public_url']       = public_url(container_name)
      header_hash['web_file_listing'] = header_hash['web_file_listing'] == 'true' # convert to Boolean
      header_hash['metadata']         = extract_metadata_data(headers, 'x-container-meta-').reject do |key, value|
        # skip metadata fields that are recognized by us
        CONTAINER_ATTRMAP.has_key?('x-container-meta-' + key)
      end
      
      header_hash
    end
    
    def extract_object_header_data(response,container_name = nil, object_path = nil)
      header_hash = map_attribute_names(extract_header_data(response), OBJECT_ATTRMAP)
      puts header_hash
      header_hash['id']               = header_hash['path'] = object_path
      header_hash['container_name']   = container_name
      header_hash['public_url']       = public_url(container_name, object_path)
      header_hash['last_modified_at'] = DateTime.httpdate(header_hash['last_modified_at']) # parse date
      header_hash['created_at']       = DateTime.strptime(header_hash['created_at'], '%s') # parse UNIX timestamp
      header_hash['expires_at']       = DateTime.strptime(header_hash['expires_at'], '%s') if header_hash.has_key?('expires_at') # optional!
      header_hash['metadata']         = extract_metadata_data(headers, 'x-object-meta-')
      header_hash
    end

    def build_custom_request_header(header_attrs)
      # stringify keys and values
      # https://stackoverflow.com/questions/34595141/process-nested-hash-to-convert-all-values-to-strings
      header_attrs.deep_merge!(header_attrs) {|_,_,v| v.to_s}
      header_attrs.stringify_keys!
      # create custom header
      Misty::HTTP::Header.new(header_attrs)
    end

    # remove duplicate slashes that might have been created by naive path
    def sanitize_path(path)
      # joining (e.g. `foo + "/" + bar`)
      path = path.gsub(/^\/+/, '/')

      # remove leading and trailing slash
      return path.sub(/^\//, '').sub(/\/$/, '')
    end

    def public_url(container_name, object_path = nil)
      # similar to https://github.com/fog/fog-openstack/blob/master/lib/fog/storage/openstack/requests/public_url.rb
      return nil if container_name.nil?
      url = "#{api.object_storage.uri}/#{CGI.escape(container_name)}"
      url << "/#{CGI.escape(object_path)}" unless object_path.nil?
      if object_path.nil?
        # path to container listing needs a trailing slash to work in a browser
        url << '/'
      else
        url << "/#{CGI.escape(object_path)}"
      end
      return url
    end

  end
end