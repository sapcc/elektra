module DomainModelServiceLayer
  module Errors
    class NotImplemented < StandardError; end  
    #class ApiError < StandardError; end
    class BadMapperClass < StandardError; end
    class MissingAttribute < StandardError; end
    #class ResourceNotFound < StandardError; end

    class ApiError < StandardError

      attr_reader :type

      def initialize(error)
        error_name = error.class.name.to_s.split('::').last
        super(error)
        @type = error_name
      end

    end

  end
end