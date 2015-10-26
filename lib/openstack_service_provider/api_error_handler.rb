module OpenstackServiceProvider
  class ApiErrorHandler
    
    # Observed error formats        
    # {"NeutronError"=>{"message"=>"Invalid network", "type"=>"", "detail"=>""}}
    def parse(e)
      result = nil
      begin
        #TODO: improove error parsing
        error_message = e.message.gsub('(Disable debug mode to suppress these details.)','')
        errors = error_message.scan(/.*excon\.error\.response.*\n.*:body\s*=>\s*"(.*).*"\n/)

        error_string = errors.flatten.first
        error_string.gsub!(/\\+"/,'"') if error_string
        parsed_errors = JSON.parse(error_string) rescue nil
        result = parsed_errors["errors"] || parsed_errors["error"] if parsed_errors
        result = parsed_errors if result.nil? and parsed_errors.is_a?(Hash)
        result = {"Error" => e.message} unless result
        p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>ERROR"
        p result
      rescue => e
        puts e
      end

      result = {'message' => e.message} unless result
      return result
    end
  end
end