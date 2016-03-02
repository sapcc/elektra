module Core
  module ServiceLayer
    class ApiErrorHandler
    
      # Observed error formats        
      # {"NeutronError"=>{"message"=>"Invalid network", "type"=>"", "detail"=>""}}
      def self.parse(e)
        result = nil
        begin
          #TODO: improove error parsing
          error_message = e.message.gsub('(Disable debug mode to suppress these details.)','')

          #errors = error_message.scan(/.*excon\.error\.response.*\n.*:body\s*=>\s*("|')(.*).*("|')\n/)
          errors = error_message.scan(/^.*excon\.error\.response.*\n.*:body\s*=>(.*)\n.*$/)
          # errors = s.scan(/^.*excon\.error\.response.*\n((.|\n)*)$/)
          
          #error_string = errors.flatten.first
          #error_string.gsub!(/\\+"/,'"') if error_string
          
          #parsed_errors = JSON.parse(error_string) rescue nil
          
          errors = errors.flatten.first
          parsed_errors = eval(eval(errors)) rescue nil
          
          s2s = 
            lambda do |h| 
              Hash === h ? 
                Hash[
                  h.map do |k, v| 
                    [k.respond_to?(:to_sym) ? k.to_sym : k, s2s[v]] 
                  end 
                ] : h 
            end

          parsed_errors = s2s[parsed_errors] if parsed_errors

          result = parsed_errors[:errors] || parsed_errors[:error]  if parsed_errors
          result = parsed_errors if result.nil? and parsed_errors.is_a?(Hash)
          result = {"Error" => e.message} unless result
        rescue => e
          puts e
        end

        result = {'message' => e.message} unless result
        return result
      end
    end
  end
end
