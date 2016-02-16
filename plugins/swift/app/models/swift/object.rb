module Swift
  class Object < DomainModelServiceLayer::Model

    # The following properties are known:
    #   - id (= path)
    #   - content_type
    #   - last_modified
    #   - md5_hash
    #   - size_bytes

    # The DomainModelServiceLayer::Model expects the object to be identified by
    # the `id` attribute. But Swift objects are identified by their path (which
    # is confusingly called "name" in Swift). The driver maps the `name`
    # attribute to "id" so that the Model base class can grok it. This alias
    # here should make high-level code using the model class more readable.
    def path
      self.id
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

    # Returns the actual file contents, using a separate API call to Swift.
    def file_contents
      @driver.get_object_contents(container_name, path)
    end

  end
end
