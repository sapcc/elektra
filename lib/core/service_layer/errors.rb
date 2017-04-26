module Core
  module ServiceLayer
    module Errors
      class NotImplemented < StandardError; end
      #class ApiError < StandardError; end
      class BadMapperClass < StandardError; end
      class MissingAttribute < StandardError; end
      #class ResourceNotFound < StandardError; end

      class ApiError < StandardError

        attr_reader :type, :response, :response_data

        def initialize(error)
          if error.respond_to?(:response)
            @response = error.response
            if error.response.get_header("content-type").include?("json")
              @response_data = JSON.parse(error.response.body)
            else
              @response_data = { text: error.response.body }
            end
          end
          if error.respond_to?(:error_name) # used by ResMgmt::Driver::Misty::BackendError
            error_name = error.error_name
          else
            error_name = error.class.name.to_s.split('::').last
          end
          super(error)
          @type = error_name
        end

      end

    end
  end
end
