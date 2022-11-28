module EmailService
  class VerifiedEmail
    include ::EmailService::Helpers

    def initialize(attributes = {})
      @attributes = attributes
    end

    attr_accessor :attributes

    def form_to_attributes(attrs)
      attrs.keys.each do |key|
        if array_attr.include? key
          attrs[key] = string_to_array(attrs[key])
        end
      end
      self.attributes.merge! attrs.stringify_keys
    end

    def attributes_to_form
      attr = self.attributes.clone
      attr.keys.each do |key|
        if array_attr.include? key.to_sym
          attr[key] = array_to_string(attr[key])
        end
      end
      attr
    end

    def respond_to?(method_name, include_private = false)
      keys = @attributes.keys
      keys.include?(method_name.to_s) or keys.include?(method_name.to_sym)
    end

    def method_missing(method_name, *args, &block)
      keys = @attributes.keys
      if keys.include?(method_name.to_s)
        @attributes[method_name.to_s]
      elsif keys.include?(method_name.to_sym)
        @attributes[method_name.to_sym]
      end
    end

    private

    def array_attr
      [:identity]
    end

  end

end
