module ResourceManagement
  class Capacity < ActiveRecord::Base
    validates_presence_of :service, :resource, :value
    validate :validate_value

    def attributes
      # get attributes for this resource
      resource_attrs = ResourceManagement::Resource::KNOWN_RESOURCES.find { |r| r[:service] == service.to_sym and r[:name] == resource.to_sym }
      # merge attributes for the resource's services
      service_attrs = ResourceManagement::Resource::KNOWN_SERVICES.find { |s| s[:service] == service.to_sym }
      return (resource_attrs || {}).merge(service_attrs || {})
    end

    def data_type
      ResourceManagement::DataType.new(attributes[:data_type] || :number)
    end

    def value=(new_value)
      if new_value.is_a?(String)
        begin
          new_value = data_type.parse(new_value)
          @value_validation_error = nil
        rescue ArgumentError => e
          # errors.add() only works during validation, so store this error for later
          @value_validation_error = e.message
          return
        end
      end
      super(new_value)
    end

    private

    def validate_value
      errors.add(:value, "is invalid: #{@value_validation_error}") if @value_validation_error
    end

  end
end
