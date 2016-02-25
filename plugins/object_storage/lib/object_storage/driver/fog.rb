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

      ##### containers

      CONTAINERS_ATTRMAP = {
        # name in API response => name in our model (that is part of this class's interface)
        'bytes' => 'bytes_used',
        'count' => 'object_count',
        'name'  => 'name',
      }
      CONTAINER_ATTRMAP = {
        'X-Container-Object-Count' => 'object_count',
        'X-Container-Bytes-Used'   => 'bytes_used',
      }
      CONTAINER_WRITE_ATTRMAP = {
        # name in our model => name in create/update API request
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
          data['metadata'] = extract_metadata_tags(headers, 'X-Container-Meta-')
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

      def empty_container(name)
        handle_response do
          object_list = self.objects(name)
          object_list.each do |o|
             @fog.delete_object(name, o["path"])
          end
          return # nothing
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
        'last_modified' => 'last_modified',
        'name'          => 'path',
        'subdir'        => 'path', # for subdirectories, only this single attribute is given
      }
      OBJECT_ATTRMAP = {
        'Content-Length' => 'size_bytes',
        'Content-Type'   => 'content_type',
        'Etag'           => 'md5_hash',
        'Last-Modified'  => 'last_modified',
      }
      OBJECT_WRITE_ATTRMAP = {
        # name in our model => name in create/update API request
      }

      def objects(container_name, options={})
        handle_response do
          list = @fog.get_container(container_name, options).body
          list.map do |o|
            object = map_attribute_names(o, OBJECTS_ATTRMAP)
            object['id'] = object['path'] # path also serves as id() for Core::ServiceLayer::Model
            object['container_name'] = container_name
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

      def get_object(container_name, path)
        handle_response do
          headers = fog_head_object(container_name, path).headers
          data = map_attribute_names(headers, OBJECT_ATTRMAP)
          data['id'] = data['path'] = path
          data['container_name'] = container_name
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

          (params['metadata'] || {}).each do |key, value|
            request_params["X-Object-Meta-#{key}"] = value
          end

          fog_post_object(params[:container_name], path, request_params)
          nil # return nothing
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

      # TODO This request is missing in Fog.
      def fog_post_object(container_name, path, headers={})
        @fog.request({
          expects: [ 201, 202 ],
          method:  'POST',
          path:    "#{::Fog::OpenStack.escape(container_name)}/#{escape_path(path)}",
          headers: headers,
        }, false)
      end

      def escape_path(path)
        return ::Fog::OpenStack.escape(path).gsub('%2F', '/')
      end

    end
  end
end

