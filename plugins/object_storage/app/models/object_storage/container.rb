module ObjectStorage
  class Container < Core::ServiceLayer::Model

      # The following properties are known:
      #   - name
      #   - object_count
      #   - bytes_used
      # The id() is identical to the name() if the container is persisted.

      validates_presence_of :name
      validate do
        # http://developer.openstack.org/api-ref-objectstorage-v1.html#createContainer
        errors[:name] << 'may not contain slashes' if name.include?('/')
        errors[:name] << 'may not contain more than 256 characters' if name.size > 256 
      end

  end
end
