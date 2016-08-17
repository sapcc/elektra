module Automation

  module Helpers

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
      else
        '{}'
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
