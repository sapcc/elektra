module ObjectStorage
  module Forms
    class ConfirmContainer < Core::ServiceLayer::Model

      def initialize(attributes={})
        super(nil, attributes) # no driver
      end

      validates_presence_of :name

    end
  end
end
