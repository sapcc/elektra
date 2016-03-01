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

      def objects_below_path(container_name, path, filter={})
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

      # Container must be specified in `params[:container_name]`.
      def update_object(path, params)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      # `options` may set the flag `with_metadata: true` to copy the source object's metadata.
      def copy_object(source_container_name, source_path, target_container_name, target_path, options={})
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def delete_object(container_name, path)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def move_object(source_container_name, source_path, target_container_name, target_path, options={})
        copy_object(source_container_name, source_path, target_container_name, target_path, options.merge(with_metadata: true))
        delete_object(source_container_name, source_path)
      end

      ##### miscellaneous

      # List capabilities of the backend. The output format is
      # backend-specific. The only thing that's guaranteed is that a hash is
      # returned, where the keys are strings that identify the available
      # capabilities. The values are whatever the backend reports for that
      # capability.
      def list_capabilities
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      # `targets` is an array of hashes like
      #
      #   { container: "foo" }                    # delete this container (must be empty!)
      #   { container: "foo", object: "bar/baz" } # delete this object
      #
      # The list of `targets` is ordered. Targets will be deleted from first to last.
      def bulk_delete(targets)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

    end
  end
end
