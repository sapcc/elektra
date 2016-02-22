module ObjectStorage
  module Forms
    class CreateContainer < Core::ServiceLayer::Model

      def initialize(attributes={})
        super(nil, attributes)
      end

      validates_presence_of :name
      validate do
        # http://developer.openstack.org/api-ref-objectstorage-v1.html#createContainer
        errors[:name] << 'may not contain slashes' if name.include?('/')
        errors[:name] << 'may not contain more than 256 characters' if name.size > 256 
      end

    end
  end
end
