module ResourceManagement
  class Capacity < ActiveRecord::Base
    validates_presence_of :service, :resource, :value
    validate :validate_value

    def config
      sn = service.to_sym
      rn = resource.to_sym
      ResourceManagement::ResourceConfig.all.find { |r| r.service_name == sn && r.name == rn }
    end

    def data_type
      config.data_type
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
