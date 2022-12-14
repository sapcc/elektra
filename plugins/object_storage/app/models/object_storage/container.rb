module ObjectStorage
  class Container < Core::ServiceLayer::Model
    # The following properties are known:
    #   - name
    #   - public_url
    #   - object_count
    #   - bytes_used
    #   - metadata (Hash)
    #   - read_acl
    #   - write_acl
    #   - versions_location (container name, see http://docs.openstack.org/developer/swift/api/object_versioning.html)
    # The id() is identical to the name() if the container is persisted.

    validates_presence_of :name
    validates_numericality_of :object_count_quota,
                              greater_than_or_equal_to: 0,
                              allow_nil: true
    validate do
      # http://developer.openstack.org/api-ref-objectstorage-v1.html#createContainer
      errors[:name] << "may not contain slashes" if name.include?("/")
      if name.size > 256
        errors[:name] << "may not contain more than 256 characters"
      end
      if @bytes_quota_validation_error
        errors[:bytes_quota] << "is invalid: #{@bytes_quota_validation_error}"
      end
      if !public_read_access? && (web_index.present? || web_file_listing?)
        errors[
          :read_acl
        ] << "may not be disabled because static website serving is enabled"
      end

      # check all containers
      if versions_location.present? or has_versions_location.present?
        errors[:versions_location] << "is missing" if versions_location.blank?
        if versions_location == name
          errors[:versions_location] << "may not be the same container"
        end
        unless @service.containers.any? { |c| c.name == versions_location }
          errors[:versions_location] << "is not a container name"
        end
      end
    end

    def after_create
      id ||= read("name")
    end

    def web_file_listing?
      read(:web_file_listing)
    end

    def public_read_access?
      read_acl == ".r:*,.rlistings"
    end

    def allows_public_access?
      # checks whether there is any form of public enablement
      (read_acl || "").match(/[.]r:/)
    end

    def object_count
      read(:object_count).to_i
    end

    def object_count_quota
      value = read(:object_count_quota)
      return nil unless value
      # to_i will return 0 if value is nil
      value.to_i
    end

    def bytes_used
      read(:bytes_used).to_i
    end

    def bytes_quota
      value = read(:bytes_quota)
      return nil unless value
      # to_i will return 0 if value is nil
      value.to_i
    end

    def bytes_quota=(new_value)
      if new_value.is_a?(String)
        begin
          unless new_value.empty?
            new_value = Core::DataType.new(:bytes).parse(new_value)
          else
            new_value = nil
          end
          @bytes_quota_validation_error = nil
        rescue ArgumentError => e
          # errors.add() only works during validation, so store this error for later
          @bytes_quota_validation_error = e.message
          return
        end
      end
      super(new_value)
    end

    def initialize(driver, attributes = {})
      super(driver, attributes)
      # the driver needs the previous set of metadata to calculate the changes during update_container()
      @original_metadata = metadata
    end

    def attributes_for_update
      super
        .merge("original_metadata" => @original_metadata)
        .reject { |k, _| k.to_s == "has_versions_location" }
    end

    def empty?
      @driver.objects(name, limit: 1).count == 0
    end
  end
end
