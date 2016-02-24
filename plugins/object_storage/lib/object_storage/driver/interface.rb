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

      def empty_container(name)
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

      # `contents` is expected to be an IO object. If you got a string, call like
      #
      #   driver.create_object(container_name, path, StringIO.new(contents))
      #
      # To create a pseudo-directory, append a slash to the path and give empty contents:
      #
      #   driver.create_object("mycontainer", "foo/bar/", StringIO.new(""))
      #
      def create_object(container_name, path, contents)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

    end
  end
end
