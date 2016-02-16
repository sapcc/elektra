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

      # TODO

    end
  end
end
