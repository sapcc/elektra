require 'active_resource'

module Automation

  class Automation < Automation::BaseAutomation
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
        elsif key == :chef_attributes
          unless attrs[key].blank?
            attrs[key] = attrs[key].to_json
          end
        end
      end

      self.attributes = attrs.stringify_keys
    end

    def attributes_to_form
      attr = self.attributes.clone
      attr.keys.each do |key|
      #   if json_attr.include? key
      #     attrs[key] = string_to_json(attrs[key])
      #   elsif array_attr.include? key
      #     attrs[key] = string_to_array(attrs[key])
      #   elsif key == :type
      #     unless attrs[key].blank?
      #       attrs[key] = attrs[key].capitalize
      #     end
      #   elsif key == :chef_attributes
      #     unless attrs[key].blank?
      #       attrs[key] = attrs[key].to_json
      #     end
      #   end
      end
      attr
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

    def string_to_array(attr)
      unless attr.blank?
        return attr.split(',')
      end
    end

  end

end
