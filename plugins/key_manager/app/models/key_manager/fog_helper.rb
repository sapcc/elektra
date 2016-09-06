module KeyManager

  module FogHelper

    def get_api_error_messages(error)
      if error.respond_to?(:response_data)
        return read_error_messages(error.response_data)
      elsif error.respond_to?(:response) and error.response.body
        response_data = JSON.parse(error.response.body) rescue error.response.body
        return read_error_messages(response_data)
      else
        [error.message]
      end
    end

    def read_error_messages(hash,messages=[])
      return [ hash.to_s ] unless hash.respond_to?(:each)
      hash.each do |k,v|
        messages << v if k=='message' or k=='type' or k=='description'
        if v.is_a?(Hash)
          read_error_messages(v,messages)
        elsif v.is_a?(Array)
          v.each do |value|
            read_error_messages(value,messages) if value.is_a?(Hash)
          end
        end
      end
      return messages
    end

  end

end