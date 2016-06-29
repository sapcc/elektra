module Core
  module ServiceLayer
    module Errors
      class NotImplemented < StandardError; end  
      #class ApiError < StandardError; end
      class BadMapperClass < StandardError; end
      class MissingAttribute < StandardError; end
      #class ResourceNotFound < StandardError; end

      class ApiError < StandardError

        attr_reader :type, :response, :response_data, :api_error_message

        def initialize(error)
          if error.respond_to?(:response)
            @response = error.response 
            @response_data = JSON.parse(error.response.body)
            #@api_error_message = @response_data.fetch("error", {}).fetch("message",nil)
          end
          error_name = error.class.name.to_s.split('::').last
          super(error)
          @type = error_name
        end

      end

    end
  end
end