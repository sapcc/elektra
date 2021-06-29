# X-OpenStack-Request-ID
require 'securerandom'

module ElektronMiddlewares
  class RequestUUID < ::Elektron::Middlewares::Base
    def initialize(next_middleware = nil)
      @next_middleware = next_middleware
    end

    def call(request_data)
      # add request uuid if internal interface is used
      if request_data.options[:interface] == "internal"
        request_data.options[:headers] ||= {}
        request_data.options[:headers]["X-OpenStack-Request-ID"] = "req-#{SecureRandom.uuid}"
      end

      # call next app
      response = @next_middleware.call(request_data)
      # now we could manipulate the response data
      # return response
      
      response
    end
  end
end
