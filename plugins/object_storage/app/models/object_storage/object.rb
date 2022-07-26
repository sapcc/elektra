module ObjectStorage
  class Object < Core::ServiceLayer::Model

    # The following properties are known:
    #   - path
    #   - public_url
    #   - content_type
    #   - created_at (DateTime)
    #   - last_modified_at (DateTime)
    #   - expires_at (DateTime)
    #   - md5_hash
    #   - size_bytes
    #   - metadata (Hash)
    # The id() is identical to the path() if the object is persisted.

    def dlo
      return "True" if read(:dlo_manifest)
    end

    def dlo_segments_container
      return .split('/')dlo_manifest.first if read(:dlo_manifest)
    end

    def dlo_segments_folder_path
      if read(:dlo_manifest)
        manifest = read(:dlo_manifest)
        manifest.slice!(dlo_segments_container)
        return manifest
      end
    end

    def size_bytes
      read(:size_bytes).to_i
    end

    def created_at
      read(:created_at)
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
      @service.object_content(container_name, path)
    end

    def ui_sort_order
      # sort directories above files
      (is_directory? ? 'a' : 'b') + self.basename
    end

    ############################################################################
    # input validation

    validates_presence_of :content_type

    validate do
      errors[:expires_at] << "is invalid: #{@expires_at_validation_error}" if @expires_at_validation_error
    end

    def expires_at=(new_value)
      if new_value.is_a?(String)
        begin
          if new_value.empty?
            new_value = nil
          else
            new_value = Time.parse(new_value + ' UTC') # force UTC
          end
          @expires_at_validation_error = nil
        rescue => e
          @expires_at_validation_error = e.message
          return
        end
      end
      super(new_value)
    end

    ############################################################################
    # actions

    def copy_to(target_container_name, target_path, options={})
      @service.copy_object(
        container_name, path, target_container_name, target_path,
        with_metadata: options[:with_metadata],
        # need to reuse Content-Type from original file, or else Fog inserts
        # its standard "Content-Type: application/json" which Swift then
        # interprets as our take on the object's content type
        content_type:  content_type,
      )
      return
    end

    def move_to!(target_container_name, target_path)
      @service.move_object(
        container_name, path, target_container_name, target_path,
        content_type: content_type, # see above for why this is needed
      )
      # after successful move, update attributes to point towards the new location
      self.attributes = attributes.merge(
        "container_name" => target_container_name,
        "id"             => target_path,
        "path"           => target_path,
      )
      return
    end

  end
end
