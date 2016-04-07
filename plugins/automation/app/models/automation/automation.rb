require 'active_resource'

module Automation

  class Automation < ::Automation::BaseAutomation
    module Types
      CHEF = 'Chef'
      SCRIPT = 'Script'
    end

    self.collection_name = "automations"

    def form_attribute(name)
      unless self.respond_to? name.to_sym
        return "Unknow attribute ''#{name}''"
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
        if key == 'chef_attributes'
          unless attr[key].blank?
            if attr[key].respond_to?(:attributes)
              attr[key] = attr[key].attributes.to_json
            end
          end
        elsif key == 'tags'
          if attr[key].respond_to?(:attributes)
            attr[key] = json_to_string(attr[key].attributes)
          end
        elsif key == 'run_list'
          attr[key] = array_to_string(attr[key])
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

    def json_to_string(attr)
      result_string = []
      attr.each do |key, value|
        result_string << "#{key}:#{value}"
      end
    end

    def string_to_json(attr)
      unless attr.blank?
        result_hash = {}
        attr.split(',').each do |tag|
          tags_array = tag.split(/\:|\=/)
          if tags_array.count == 2
            result_hash[tags_array[0]] = tags_array[1]
          end
        end
        unless result_hash.empty?
          return result_hash.to_json
        end
      end
    end

    def json_to_string(attr)
      result_string = ""
      unless attr.blank?
        attr.each do |key, value|
          result_string << "#{key}:#{value},"
        end
      end
      if result_string.length > 0
        # remove the last coma
        result_string = result_string[0..-2]
      end
      result_string
    end

    def string_to_array(attr)
      unless attr.blank?
        return attr.split(',')
      end
    end

    def array_to_string(attr)
      unless attr.blank?
        return attr.join(',')
      end
    end


  end

end
