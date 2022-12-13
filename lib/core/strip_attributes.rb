require "active_model"

module ActiveModel::Validations::HelperMethods
  # Strips whitespace from model fields and converts blank values to nil.
  def strip_attributes()
    before_validation { |record| ::Core::StripAttributes.strip(record) }
  end
end

module Core
  module StripAttributes
    def self.strip(record_or_string)
      if record_or_string.respond_to?(:attributes)
        strip_record(record_or_string)
      else
        strip_string(record_or_string)
      end
    end

    def self.strip_record(record)
      attributes = record.attributes

      attributes.each do |attr, value|
        original_value = value
        value = strip_string(value)
        if original_value != value
          if record.respond_to?(:write)
            # elektra std model
            record.write(attr, value)
          elsif record.respond_to?(:attributes=)
            # model with virtus
            record.attributes = { attr => value }
          else
            # model with fog
            record.attributes[attr.to_sym] = value
          end
        end
      end

      record
    end

    def self.strip_string(value)
      if value.respond_to?(:strip)
        value = value.strip unless value.blank?
      end

      value
    end
  end
end
