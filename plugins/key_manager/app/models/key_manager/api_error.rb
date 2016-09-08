module KeyManager

  class ApiError < StandardError

    attr :response

    def initialize(data)
      super
      @response = data.respond_to?(:response) ? data.response : data
    end

    def description
      if !@response.nil? && @response.respond_to?(:body) && !@response.body.nil?
        data = JSON.parse(@response.body) rescue @response.body
        meesages = read_error_messages(data)
        return meesages.join(", ")
      end
      @response.inspect.to_s
    end

    def title
      res = "API Error"
      unless @response.nil?
        if @response.respond_to?(:reason_phrase)
          return @response.reason_phrase
        else
          return res
        end
      end
      return res
    end

    def details
      @response.inspect.to_s
    end

    private

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