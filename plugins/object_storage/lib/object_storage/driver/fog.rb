module ObjectStorage
  module Driver
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper

      def initialize(params_or_driver)
        # support initialization by given driver
        if params_or_driver.is_a?(::Fog::Storage::OpenStack)
          @fog = params_or_driver
        else
          super(params_or_driver)
          @fog = ::Fog::Storage::OpenStack.new(auth_params)
        end
      end

      def list_capabilities
        handle_response do
          # this request is not project-scoped and thus cannot go through
          # @fog.request(); OTOH it does not need a token which makes stuff
          # easier for us
          @capabilities ||= ::Fog::JSON.decode(@fog.instance_variable_get(:@connection).request({
            expects: 200,
            headers: { 'Accept' => 'application/json' },
            method:  'GET',
            path:    'info',
          }).body)
        end
      end

      ##### containers

      CONTAINERS_ATTRMAP = {
        # name in API response => name in our model (that is part of this class's interface)
        'bytes' => 'bytes_used',
        'count' => 'object_count',
        'name'  => 'name',
      }
      CONTAINER_ATTRMAP = {
        # name in API => name in our model
        'X-Container-Object-Count'      => 'object_count',
        'X-Container-Bytes-Used'        => 'bytes_used',
        'X-Container-Meta-Quota-Bytes'  => 'bytes_quota',
        'X-Container-Meta-Quota-Count'  => 'object_count_quota',
        'X-Container-Read'              => 'read_acl',
        'X-Container-Write'             => 'write_acl',
        'X-Versions-Location'           => 'versions_location',
        'X-Container-Meta-Web-Index'    => 'web_index',
        'X-Container-Meta-Web-Listings' => 'web_file_listing',
      }
      CONTAINER_WRITE_ATTRMAP = {
        # name in our model => name in create/update API request
        'bytes_quota'        => 'X-Container-Meta-Quota-Bytes',
        'object_count_quota' => 'X-Container-Meta-Quota-Count',
        'read_acl'           => 'X-Container-Read',
        'write_acl'          => 'X-Container-Write',
        'versions_location'  => 'X-Versions-Location',
        'web_index'          => 'X-Container-Meta-Web-Index',
        'web_file_listing'   => 'X-Container-Meta-Web-Listings',
      }

      def containers(filter={})
        handle_response do
          list = @fog.get_containers.body
          list.map do |c|
            container = map_attribute_names(c, CONTAINERS_ATTRMAP)
            container['id'] = container['name'] # name also serves as id() for Core::ServiceLayer::Model
            container
          end
        end
      end

      def get_container(name)
        handle_response do
          headers = @fog.head_container(name).headers
          data = map_attribute_names(headers, CONTAINER_ATTRMAP)
          data['id'] = data['name'] = name
          data['public_url'] = fog_public_url(name)
          data['web_file_listing'] = data['web_file_listing'] == 'true' # convert to Boolean
          data['metadata']   = extract_metadata_tags(headers, 'X-Container-Meta-').reject do |key, value|
            # skip metadata fields that are recognized by us
            not CONTAINER_ATTRMAP.has_key?(key)
          end
          data
        end
      end

      def create_container(params={})
        handle_response do
          update_container(params[:name], params)
          params
        end
      end

      def update_container(name, params={})
        handle_response do
          request_params = map_attribute_names(params, CONTAINER_WRITE_ATTRMAP)

          # convert difference between old and new metadata into a set of changes
          old_metadata = params['original_metadata']
          new_metadata = params['metadata']
          if old_metadata.nil? && !new_metadata.nil?
            raise InputError, 'cannot update metadata without knowing the current metadata'
          end
          (old_metadata || {}).each do |key, value|
            unless new_metadata.has_key?(key)
              request_params["X-Remove-Container-Meta-#{key}"] = "1"
            end
          end
          (new_metadata || {}).each do |key, value|
            if old_metadata[key] != value
              request_params["X-Container-Meta-#{key}"] = value
            end
          end

          @fog.put_container(name, headers: request_params)
          nil # return nothing
        end
      end

      def delete_container(name)
        # TODO: this works only for empty containers 
        #       If the container exists but is not empty, the response is "There was a conflict when trying to complete
        #       your request."
        handle_response { @fog.delete_container(name) }
      end

      ##### objects

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
        'Content-Length' => 'size_bytes',
        'Content-Type'   => 'content_type',
        'Etag'           => 'md5_hash',
        'Last-Modified'  => 'last_modified_at',
        'X-Timestamp'    => 'created_at',
        'X-Delete-At'    => 'expires_at',
      }
      OBJECT_WRITE_ATTRMAP = {
        # name in our model => name in create/update API request
        'content_type'   => 'Content-Type',
        # 'expires_at'     => 'X-Delete-At', # this is special-cased in update_object()
      }

      def objects(container_name, options={})
        handle_response do
          list = @fog.get_container(container_name, options).body
          list.map do |o|
            object = map_attribute_names(o, OBJECTS_ATTRMAP)
            object['id'] = object['path'] # path also serves as id() for Core::ServiceLayer::Model
            object['container_name'] = container_name
            if object.has_key?('last_modified_at')
              object['last_modified_at'] = DateTime.iso8601(object['last_modified_at']) # parse date
            end
            object
          end
        end
      end

      def objects_at_path(container_name, path, filter={})
        path += '/' if !path.end_with?('/') && !path.empty?
        result = objects(container_name, filter.merge(prefix: path, delimiter: '/'))
        # if there is a pseudo-folder at `path`, it will be in the result, too;
        # filter this out since we only want stuff below `path`
        return result.reject { |obj| obj['id'] == path }
      end

      def objects_below_path(container_name, path, filter={})
        path += '/' if !path.end_with?('/') && !path.empty?
        return objects(container_name, filter.merge(prefix: path))
      end

      def get_object(container_name, path)
        handle_response do
          headers = fog_head_object(container_name, path).headers
          data = map_attribute_names(headers, OBJECT_ATTRMAP)
          data['id'] = data['path'] = path
          data['container_name'] = container_name
          data['public_url']     = fog_public_url(container_name, path)
          data['last_modified_at'] = DateTime.httpdate(data['last_modified_at']) # parse date
          data['created_at']       = DateTime.strptime(data['created_at'], '%s') # parse UNIX timestamp
          data['expires_at']       = DateTime.strptime(data['expires_at'], '%s') if data.has_key?('expires_at') # optional!
          data['metadata'] = extract_metadata_tags(headers, 'X-Object-Meta-')
          data
        end
      end

      def get_object_contents(container_name, path)
        handle_response { fog_get_object(container_name, path).body }
      end

      def create_object(container_name, path, contents)
        handle_response do
          # `contents` is an IO object to allow for easy for future expansion to
          # more clever upload strategies (e.g. SLO); for now, we just send
          # everything at once
          @fog.put_object(container_name, path, contents.read)
        end
      end

      def update_object(path, params)
        handle_response do
          request_params = map_attribute_names(params, OBJECT_WRITE_ATTRMAP)

          unless params['expires_at'].nil?
            request_params['X-Delete-At'] = params['expires_at'].getutc.strftime('%s')
          end

          (params['metadata'] || {}).each do |key, value|
            request_params["X-Object-Meta-#{key}"] = value
          end

          fog_post_object(params[:container_name], path, request_params)
          nil # return nothing
        end
      end

      def copy_object(source_container_name, source_path, target_container_name, target_path, options={})
        handle_response do
          headers = {}
          headers['X-Fresh-Metadata'] = 'True' unless options[:with_metadata]
          headers['Content-Type'] = options[:content_type] if options[:content_type]

          fog_copy_object(source_container_name, source_path, target_container_name, target_path, headers)
        end
      end

      def delete_object(container_name, path)
        handle_response { fog_delete_object(container_name, path) }
      end

      def bulk_delete(targets)
        list_capabilities
        if @capabilities.has_key?('bulk_delete')
          handle_response do
            # assemble the request body containing the paths to all targets
            body = ""
            targets.each do |target|
              unless target.has_key?(:container)
                raise ArgumentError, "malformed target #{target.inspect}"
              end
              body += ::Fog::OpenStack.escape(target[:container])
              if target.has_key?(:object)
                body += "/" + escape_path(target[:object])
              end
              body += "\n"
            end
  
            # TODO: the bulk delete request is missing in Fog
            @fog.request({
              expects: 200,
              method:  'DELETE',
              path:    '',
              query:   { 'bulk-delete' => 1 },
              headers: { 'Content-Type' => 'text/plain' },
              body:    body,
            })
          end
        else
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
        end
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

      # Like @fog.get_object(), but encodes the `path` correctly. TODO: fix in Fog
      def fog_get_object(container_name, path)
        @fog.request({
          :expects  => 200,
          :method   => 'GET',
          :path     => "#{::Fog::OpenStack.escape(container_name)}/#{escape_path(path)}"
        }, false)
      end

      # Like @fog.head_object(), but encodes the `path` correctly. TODO: fix in Fog
      def fog_head_object(container_name, path)
        @fog.request({
          :expects  => 200,
          :method   => 'HEAD',
          :path     => "#{::Fog::OpenStack.escape(container_name)}/#{escape_path(path)}"
        }, false)
      end

      # Like @fog.copy_object(), but encodes the path correctly. TODO: fix in Fog
      def fog_copy_object(source_container_name, source_object_name, target_container_name, target_object_name, options={})
        headers = { 'X-Copy-From' => "/#{source_container_name}/#{source_object_name}" }.merge(options)
        @fog.request({
          :expects  => 201,
          :headers  => headers,
          :method   => 'PUT',
          :path     => "#{::Fog::OpenStack.escape(target_container_name)}/#{escape_path(target_object_name)}"
        })
      end

      # TODO This request is missing in Fog.
      def fog_post_object(container_name, path, headers={})
        @fog.request({
          expects: [ 201, 202 ],
          method:  'POST',
          path:    "#{::Fog::OpenStack.escape(container_name)}/#{escape_path(path)}",
          headers: headers,
        }, false)
      end

      # Like @fog.delete_object(), but encodes the `path` correctly. TODO: fix in Fog
      def fog_delete_object(container_name, path)
        @fog.request({
          expects: 204,
          method:  'DELETE',
          path:    "#{::Fog::OpenStack.escape(container_name)}/#{escape_path(path)}"
        }, false)
      end

      # Like @fog.public_url(), but encodes the `object` correctly. TODO: fix in Fog
      def fog_public_url(container=nil, object=nil)
        return nil if container.nil?
        url = @fog.public_url(container)
        url << "/#{escape_path(object)}" unless object.nil?
        return url
      end

      def escape_path(path)
        return ::Fog::OpenStack.escape(path).gsub('%2F', '/')
      end

    end
  end
end

