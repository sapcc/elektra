module ObjectStorage
  module Forms
    class CreateFolder < Core::ServiceLayerNg::Model

      def initialize(attributes={})
        super(nil, attributes) # no driver
      end

      validates_presence_of :name
      validate do
        errors[:name] << 'may not have trailing slashes' if name.end_with?('/')
      end

    end
  end
end
