module OpenstackServiceProvider
  module Errors
    class NotImplemented < StandardError; end  
    class ApiError < StandardError; end
    class BadMapperClass < StandardError; end
    class MissingAttribute < StandardError; end
  end
end