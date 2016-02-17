module ObjectStorage
  module Driver
    class Interface < Core::ServiceLayer::Driver::Base

      ##### containers

      def containers(filter={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def get_container(name)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def create_container(params={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def update_container(name, params={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def delete_container(name)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      ##### objects

      def objects(container_name, filter={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def objects_at_path(container_name, path, filter={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def get_object(container_name, path)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def get_object_contents(container_name, path)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

    end
  end
end
