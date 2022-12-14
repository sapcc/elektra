require "mail"
module EmailService
  module Helpers
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    EMAIL_SEPARATOR = ","

    def string_to_hash(attr)
      unless attr.blank?
        result_hash = {}
        attr
          .split(EMAIL_SEPARATOR)
          .each do |tag|
            tags_array = tag.split(/\:|\=/)
            result_hash[tags_array[0]] = tags_array[1] if tags_array.count == 2
          end
        return result_hash unless result_hash.empty?
      else
        {}
      end
    end

    def json_to_string(attr)
      result_string = ""
      unless attr.blank?
        attr.each do |key, value|
          result_string << "#{key}:#{value}#{EMAIL_SEPARATOR}"
        end
        result_string.chomp! EMAIL_SEPARATOR
      end
      result_string
    end

    def string_to_array(attr)
      return attr.split EMAIL_SEPARATOR unless attr.blank?
      return []
    end

    def array_to_string(attr)
      return attr.join EMAIL_SEPARATOR unless attr.blank?
      return ""
    end
  end
end
