require 'mail'
module EmailService

  module Helpers

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    TAG_SEPERATOR = ","

    def is_valid_email?(str)
      str.strip.match(VALID_EMAIL_REGEX).nil? ? false : true
    end

    def templated_email_instance
      EmailService::TemplatedEmail
    end
    
    def string_to_hash(attr)
      unless attr.blank?
        result_hash = {}
        attr.split(TAG_SEPERATOR).each do |tag|
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

    def string_to_email_array(str)
      addr_arr = []
      unless str.blank?
        items = str.split TAG_SEPERATOR
        items.each do | item |
          addr_arr << item.strip unless !is_valid_email?(item)
        end
      end
      addr_arr
    end

    def json_to_string(attr)
      result_string = ""
      unless attr.blank?
        attr.each do |key, value|
          result_string << "#{key}:#{value}#{TAG_SEPERATOR}"
        end
        result_string.chomp! TAG_SEPERATOR
      end
      result_string
    end

    def string_to_array(attr)
      unless attr.blank?
        return attr.split TAG_SEPERATOR
      end
      return []
    end

    def array_to_string(attr)
      unless attr.blank?
        return attr.join TAG_SEPERATOR
      end
      return ""
    end


  end

end