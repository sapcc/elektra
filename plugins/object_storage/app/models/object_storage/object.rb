module ObjectStorage
  class Object < Core::ServiceLayer::Model

    # The following properties are known:
    #   - path
    #   - content_type
    #   - last_modified
    #   - md5_hash
    #   - size_bytes
    #   - metadata (Hash)
    # The id() is identical to the path() if the object is persisted.

    def size_bytes
      read(:size_bytes).to_i
    end

    # Same as path(), but removes the trailing slash for directories.
    def clean_path
      path.end_with?('/') ? path.chop : path
    end

    def is_directory?
      path.end_with?('/')
    end
    def is_file?
      !is_directory?
    end

    # Returns the basename portion of `self.path`, i.e. the name of this
    # object. For directories, this will include a trailing slash.
    def basename
      /[^\/]*\/?$/.match(path)[0]
    end

    # Returns the dirname portion of `self.path`, i.e. the path to the
    # directory that contains this object.
    def dirname
      path.sub(/\/?[^\/]*\/?$/, '')
    end

    # Returns the actual file contents, using a separate API call.
    def file_contents
      @driver.get_object_contents(container_name, path)
    end

    def ui_sort_order
      # sort directories above files
      (is_directory? ? 'a' : 'b') + self.basename
    end

    ############################################################################
    # actions

    def copy_to(target_container_name, target_path)
      @driver.copy_object(container_name, path, target_container_name, target_path)
    end

  end
end
