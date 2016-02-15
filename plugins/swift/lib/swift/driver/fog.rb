module Swift
  module Driver
    class Fog < Interface
      include DomainModelServiceLayer::FogDriver::ClientHelper

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
        # name in response => name in result (that is part of this class's interface)
        'bytes' => 'bytes_used',
        'count' => 'object_count',
        'name'  => 'id', # because DomainModelServiceLayer::Model needs an id() attribute
      }
      CONTAINER_ATTRMAP = {
        'X-Container-Object-Count' => 'object_count',
        'X-Container-Bytes-Used'   => 'bytes_used',
      }

      def containers(filter={})
        handle_response do
          list = @fog.get_containers.body
          list.map { |c| map_attribute_names(c, CONTAINERS_ATTRMAP) }
        end
      end

      def get_container(name)
        handle_response do
          data = map_attribute_names(@fog.head_container(name).headers, CONTAINER_ATTRMAP)
          data['id'] = name
          data
        end
      end

      def create_container(name, params={})
        # TODO: map attribute names
        handle_response { @fog.put_container(name, params) }
      end

      def update_container(name, params={})
        # TODO: map attribute names
        handle_response { @fog.put_container(name, params) }
      end

      def delete_container(name)
        # TODO: map attribute names
        handle_response { @fog.delete_container(name) }
      end

      ##### objects

      # TODO (also update interface.rb accordingly!)

      private

      # Rename keys in `data` using the `attribute_map` and delete unknown keys.
      def map_attribute_names(data, attribute_map)
        data.transform_keys { |k| attribute_map.fetch(k, nil) }.reject { |key,_| key.nil? }
      end

    end
  end
end

