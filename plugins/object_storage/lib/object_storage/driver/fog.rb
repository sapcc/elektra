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
          data = map_attribute_names(@fog.head_container(name).headers, CONTAINER_ATTRMAP)
          data['id'] = data['name'] = name
          data
        end
      end

      def create_container(params={})
        handle_response do
          request_params = map_attribute_names(params, CONTAINER_WRITE_ATTRMAP)
          @fog.put_container(params[:name], request_params)
          return params.merge(id: params[:name])
        end
      end

      def update_container(name, params={})
        handle_response do
          request_params = map_attribute_names(params, CONTAINER_WRITE_ATTRMAP)
          @fog.put_container(name, request_params)
          return # nothing
        end
      end

      def delete_container(name)
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
        return objects(container_name, filter.merge(prefix: path, delimiter: '/'))
      end

      def get_object(container_name, path)
        handle_response do
          data = map_attribute_names(fog_head_object(container_name, path).headers, OBJECT_ATTRMAP)
          data['id'] = data['path'] = path
          data['container_name'] = container_name
          data
        end
      end

      def get_object_contents(container_name, path)
        handle_response { fog_get_object(container_name, path).body }
      end

      private

      # Rename keys in `data` using the `attribute_map` and delete unknown keys.
      def map_attribute_names(data, attribute_map)
        data.transform_keys { |k| attribute_map.fetch(k, nil) }.reject { |key,_| key.nil? }
      end

      # Like @fog.get_object(), but encodes the `path` correctly. TODO: fix in Fog
      def fog_get_object(container_name, path)
        @fog.request({
          :expects  => 200,
          :method   => 'GET',
          :path     => "#{::Fog::OpenStack.escape(container_name)}/#{path}"
        }, false)
      end

      # Like @fog.head_object(), but encodes the `path` correctly. TODO: fix in Fog
      def fog_head_object(container_name, path)
        @fog.request({
          :expects  => 200,
          :method   => 'HEAD',
          :path     => "#{::Fog::OpenStack.escape(container_name)}/#{path}"
        }, false)
      end

    end
  end
end

