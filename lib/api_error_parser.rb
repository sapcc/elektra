class ApiErrorParser
  class << self
    def handle(e)
      result = {@class_name => e.message}

      begin
        #TODO: improove error parsing
        error_message = e.message.gsub('(Disable debug mode to suppress these details.)','')
        errors = error_message.scan(/.*excon\.error\.response.*\n.*:body\s*=>\s*"(.*).*"\n/)
        error_string = errors.flatten.first
        error_string.gsub!(/\\+"/,'"') if error_string
        parsed_errors = JSON.parse(error_string)
        result = parsed_errors["errors"] || parsed_errors["error"]
        result = parsed_errors if result.nil? and parsed_errors.is_a?(Hash)
        result = {"Error" => e.message} unless result
        result
      rescue => e
        puts e
      end

      return result
    end
  end
end
