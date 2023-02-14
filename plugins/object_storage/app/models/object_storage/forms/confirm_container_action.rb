module ObjectStorage
  module Forms
    class ConfirmContainerAction < Core::ServiceLayer::Model
      def initialize(attributes = {})
        super(nil, attributes) # no driver
      end

      validates_presence_of :name
      validate { errors[:name] << "not correct!" if name != container_name }
    end
  end
end
