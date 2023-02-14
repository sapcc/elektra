module ObjectStorage
  module Forms
    class CreateObject < Core::ServiceLayer::Model
      def initialize(attributes = {})
        super(nil, attributes) # no driver
      end

      validates_presence_of :file, :name
      validate do
        errors[:name] << "may not have trailing slashes" if name.end_with?("/")
      end
    end
  end
end
