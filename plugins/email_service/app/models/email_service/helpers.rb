require 'mail'
module EmailService

  module Helpers

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    EMAIL_SEPARATOR = ","

    def string_to_hash(attr)
      unless attr.blank?
        result_hash = {}
        attr.split(EMAIL_SEPARATOR).each do |tag|
          tags_array = tag.split(/\:|\=/)
          if tags_array.count == 2
            result_hash[tags_array[0]] = tags_array[1]
          end
        end
        unless result_hash.empty?
          return result_hash
        end
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
      unless attr.blank?
        return attr.split EMAIL_SEPARATOR
      end
      return []
    end

    def array_to_string(attr)
      unless attr.blank?
        return attr.join EMAIL_SEPARATOR
      end
      return ""
    end

  end

end
