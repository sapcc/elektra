module EmailService
  class VerifiedDomain

    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ::EmailService::Helpers

    module KeyLength
      RSA_1024_BIT = 'RSA_1024_BIT'
      RSA_2048_BIT = 'RSA_2048_BIT'
    end

    def self.key_length
      {RSA_1024_BIT: ::EmailService::VerifiedDomain::KeyLength::RSA_1024_BIT, RSA_2048_BIT: ::EmailService::VerifiedDomain::KeyLength::RSA_2048_BIT}
    end


    def to_model
      self
    end

    def persisted?
      false
    end

    def form_to_attributes(attrs)
      attrs.keys.each do |key|
        if array_attr.include? key
          attrs[key] = string_to_array(attrs[key])
        end
      end
      Rails.logger.debug "\n *****  [form_to_attributes] - attrs.inspect - #{attrs.inspect} - ***** \n"
      self.attributes.merge! attrs.stringify_keys
    end

    def attributes_to_form
      attr = self.attributes.clone
      attr.keys.each do |key|
        if array_attr.include? key.to_sym
          attr[key] = array_to_string(attr[key])
        end
      end
      Rails.logger.debug "\n ***** [attributes_to_form] - attrs.inspect - #{attr.inspect} - ***** \n"
      attr
    end

    private

    def assign_errors(messages)
      messages.each do |key, value|
        value.each do |item|
          errors.add key.to_sym, item
        end
      end
    end


    def array_attr
      [:tags]
    end

  end
end
