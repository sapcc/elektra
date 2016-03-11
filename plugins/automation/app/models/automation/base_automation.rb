require 'active_resource'

module Automation

  class BaseAutomation < ActiveResource::Base
    cattr_accessor :static_headers
    self.static_headers = headers

    self.collection_name = "automations"

    class << self
      attr_accessor :token
    end

    def self.headers
      new_headers = static_headers.clone
      unless self.token.blank?
        new_headers['X-Auth-Token'] = self.token
      end
      new_headers
    end

    def form_attribute(name)
      unless self.respond_to? name.to_sym
        return "Unknow attribute ''#{name}''"
      end
      self.send(name.to_sym)
    end

    def form_to_attributes(attrs)
      json_attr = [:tags, :environment]
      array_attr = [:run_list, :arguments]

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

      self.attributes = {automation: attrs.stringify_keys}.merge!(attrs.stringify_keys)
    end

    def attributes_to_form
    end

    private

    def string_to_json(attr)
      unless attr.blank?
        tags_hash = {}
        attr.split(',').each do |tag|
          tags_array = tag.split(/\:|\=/)
          if tags_array.count == 2
            tags_hash[tags_array[0]] = tags_array[1]
          end
        end
        unless tags_hash.empty?
          return tags_hash.to_json
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
