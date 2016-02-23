module ObjectStorage
  module Forms
    class ConfirmContainer < Core::ServiceLayer::Model

      def initialize(attributes={})
        super(nil, attributes) # no driver
      end

      validates_presence_of :name
      validate do
        errors[:name] << "not correct! please type #{container_name}" if name != container_name
      end

    end
  end
end
