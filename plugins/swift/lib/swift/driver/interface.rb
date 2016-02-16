module Swift
  module Driver
    class Interface < DomainModelServiceLayer::Driver::Base

      ##### containers

      def containers(filter={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def get_container(name)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def create_container(params={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def update_container(name, params={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def delete_container(name)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      ##### objects

      def objects(container_name, filter={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def objects_at_path(container_name, path, filter={})
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

      def get_object(container_name, path)
        raise DomainModelServiceLayer::Errors::NotImplemented
      end

    end
  end
end
