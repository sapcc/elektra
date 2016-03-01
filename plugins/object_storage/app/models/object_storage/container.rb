module ObjectStorage
  class Container < Core::ServiceLayer::Model

    # The following properties are known:
    #   - name
    #   - object_count
    #   - bytes_used
    #   - metadata (Hash)
    # The id() is identical to the name() if the container is persisted.

    validates_presence_of :name
    validate do
      # http://developer.openstack.org/api-ref-objectstorage-v1.html#createContainer
      errors[:name] << 'may not contain slashes' if name.include?('/')
      errors[:name] << 'may not contain more than 256 characters' if name.size > 256
    end

    def object_count
      read(:object_count).to_i
    end

    def bytes_used
      read(:bytes_used).to_i
    end

    def initialize(driver, attributes={})
      super(driver, attributes)
      # the driver needs the previous set of metadata to calculate the changes during update_container()
      @original_metadata = metadata
    end

    def attributes_for_update
      super.merge('original_metadata' => @original_metadata)
    end

    def empty?
      @driver.objects(name, limit: 1).count == 0
    end

    def empty!
      # bulk-delete all objects in the container
      container_name = self.name
      targets = @driver.objects(container_name).map do |obj|
        { container: container_name, object: obj['path'] }
      end
      @driver.bulk_delete(targets)
    end

  end
end
