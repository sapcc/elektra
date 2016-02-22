module ObjectStorage
  module Forms
    class CreateContainer < Core::ServiceLayer::Model

      def initialize(attributes={})
        super(nil, attributes)
      end

      validates_presence_of :name
      validate do
        # http://developer.openstack.org/api-ref-objectstorage-v1.html#createContainer
        errors[:name] << 'slash is not an allowed character.' if name.include?('/')
        errors[:name] << 'not more than 256 characters are allowed.' if name.size > 256 
      end

    end
  end
end
