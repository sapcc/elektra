module ObjectStorage
  module Forms
    class EditObjectPath < Core::ServiceLayer::Model
      def initialize(attributes = {})
        super(nil, attributes) # no driver
      end

      validates_presence_of :container_name, :path
      validate do
        if container_name.include?("/")
          errors[:container_name] << "may not contain slashes"
        end
        errors[:container_name] << "is too long" if container_name.size > 256

        errors[:path] << "may not have trailing slashes" if path.end_with?("/")

        if source_container_name == container_name
          errors[:path] << "is identical to source path" if source_path == path
        end
      end
    end
  end
end
