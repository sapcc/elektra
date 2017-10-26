module Automation

  module Helpers

    TAG_SEPERATOR = "¡"

    def string_to_json(attr)
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
