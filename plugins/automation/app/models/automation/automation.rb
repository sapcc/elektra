require "lyra_client"

module Automation
  class Automation < LyraClient::Base
    include ::Automation::Helpers

    module Types
      CHEF = "Chef"
      SCRIPT = "Script"
    end

    self.collection_name = "automations"

    def form_attribute(name)
      attributes.fetch(name, "")
    end

    def form_to_attributes(attrs)
      attrs.keys.each do |key|
        if json_attr.include? key
          attrs[key] = string_to_hash(attrs[key])
        elsif array_attr.include? key
          attrs[key] = string_to_array(attrs[key])
        elsif key == :type
          attrs[key] = attrs[key].capitalize unless attrs[key].blank?
        elsif key == :chef_attributes
          if attrs[key].blank?
            attrs[key] = {}
          else
            attrs[key] = JSON.parse(attrs[key])
          end
        end
      end

      self.attributes.merge! attrs.stringify_keys
    end

    def attributes_to_form
      attr = self.attributes.clone
      attr.keys.each do |key|
        if json_attr.include? key.to_sym
          attr[key] = json_to_string(attr[key])
        elsif array_attr.include? key.to_sym
          attr[key] = array_to_string(attr[key])
        elsif key == "chef_attributes"
          attr[key] = attr[key].to_json unless attr[key].blank?
        end
      end
      attr
    end

    def show_chef_attributes
      result = nil
      if !self.chef_attributes.blank? &&
           self.chef_attributes.respond_to?(:attributes)
        result = self.chef_attributes.attributes
      end
      return
    end

    def self.types
      {
        script: ::Automation::Automation::Types::SCRIPT,
        chef: ::Automation::Automation::Types::CHEF,
      }
    end

    def respond_to?(method_name, include_private = false)
      keys = @attributes.keys
      keys.include?(method_name.to_s) or keys.include?(method_name.to_sym) or
        super
    end

    def method_missing(method_name, *args, &block)
      keys = @attributes.keys
      if keys.include?(method_name.to_s)
        @attributes[method_name.to_s]
      elsif keys.include?(method_name.to_sym)
        @attributes[method_name.to_sym]
      else
        super
      end
    end

    private

    def json_attr
      %i[tags environment]
    end

    def array_attr
      %i[run_list arguments]
    end
  end
end
