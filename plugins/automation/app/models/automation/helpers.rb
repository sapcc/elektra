module Automation
  module Helpers
    TAG_SEPERATOR = "¡"

    def string_to_hash(attr)
      unless attr.blank?
        result_hash = {}
        attr
          .split(TAG_SEPERATOR)
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
          result_string << "#{key}:#{value}#{TAG_SEPERATOR}"
        end
        result_string.chomp! TAG_SEPERATOR
      end
      result_string
    end

    def string_to_array(attr)
      return attr.split TAG_SEPERATOR unless attr.blank?
      return []
    end

    def array_to_string(attr)
      return attr.join TAG_SEPERATOR unless attr.blank?
      return ""
    end
  end
end
