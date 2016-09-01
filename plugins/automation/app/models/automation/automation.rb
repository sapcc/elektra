require 'active_resource'

module Automation

  class Automation < ::Automation::BaseActiveResource

    #
    # Added attribute classes to fix the activeresource load nested hashes with special keys like docker-compos
    #
    class Environment < ActiveResource::Base
      def initialize(attributes = {}, persisted = false)
        @attributes     = attributes.with_indifferent_access
        @prefix_options = {}
        @persisted = persisted
      end
    end
    class Tags < ActiveResource::Base
      def initialize(attributes = {}, persisted = false)
        @attributes     = attributes.with_indifferent_access
        @prefix_options = {}
        @persisted = persisted
      end
    end
    class ChefAttributes < ActiveResource::Base
      def initialize(attributes = {}, persisted = false)
        @attributes     = attributes.with_indifferent_access
        @prefix_options = {}
        @persisted = persisted
      end
    end


    module Types
      CHEF = 'Chef'
      SCRIPT = 'Script'
    end

    self.collection_name = "automations"

    def form_attribute(name)
      unless self.respond_to? name.to_sym
        return "Unknown attribute ''#{name}''"
      end
      self.send(name.to_sym)
    end

    def form_to_attributes(attrs)
      attrs.keys.each do |key|
        if json_attr.include? key
          attrs[key] = string_to_json(attrs[key])
        elsif array_attr.include? key
          attrs[key] = string_to_array(attrs[key])
        elsif key == :type
          unless attrs[key].blank?
            attrs[key] = attrs[key].capitalize
          end
        end
      end

      self.attributes.merge! attrs.stringify_keys
    end

    def attributes_to_form
      attr = self.attributes.clone
      attr.keys.each do |key|
        if json_attr.include? key.to_sym
          if attr[key].respond_to?(:attributes)
            attr[key] = json_to_string(attr[key].attributes)
          end
        elsif array_attr.include? key.to_sym
          attr[key] = array_to_string(attr[key])
        elsif key == 'chef_attributes'
          unless attr[key].blank?
            if attr[key].respond_to?(:attributes)
              attr[key] = attr[key].attributes.to_json
            end
          end
        end
      end
      attr
    end

    def show_chef_attributes
      result = nil
      if !self.chef_attributes.blank? && self.chef_attributes.respond_to?(:attributes)
        result = self.chef_attributes.attributes
      end
      return
    end

    def self.types
      {script: ::Automation::Automation::Types::SCRIPT, chef: ::Automation::Automation::Types::CHEF}
    end

    private

    def json_attr
      [:tags, :environment]
    end

    def array_attr
      [:run_list, :arguments]
    end

  end

end
