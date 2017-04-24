module Core
  module ServiceLayer
    class ApiErrorHandler

      def self.get_api_error_messages(error)
        puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        if error.respond_to?(:response_data) and error.response_data
          puts "case 1"
          return read_error_messages(error.response_data)
        elsif error.respond_to?(:response) and error.response and error.response.body
          puts "case 2"
          response_data = JSON.parse(error.response.body) rescue error.response.body
          return read_error_messages(response_data)
        else
          puts "case 3"

          # try to parse error from exception
          # match_data = error.message.to_s.match(/.*excon\.error\.response\n.*:body.*=>.*message[^:]*:([^,]*)/)
          match_data = error.message.to_s.match(/excon\.error\.response.+:body.+=>.+\"{.*}\"/)

          puts "ERROR: \n #{error.message.to_s}"
          puts "---------------------------------------------------------------------------------------------------------------"
          puts "MATCH: #{match_data}"

          message = if match_data and match_data.length>1
            # in this case an excon error message was found
            match_data[1].gsub(/\\+/,'').gsub('"','') rescue error.message
          else
            # no excon error, use error message as is
            error.message
          end
          [message]
        end
      end

      def self.read_error_messages(hash,messages=[])
        return [ hash.to_s ] unless hash.respond_to?(:each)
        hash.each do |k,v|
          # title and description are related to monasca error response
          messages << v if k=='message' or k=='type' or k=='title' or k=='description'
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
end
