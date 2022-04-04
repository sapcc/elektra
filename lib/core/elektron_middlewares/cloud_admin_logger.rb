require 'elektron'

module Core 
  module ElektronMiddlewares
    class CloudAdminLogger < Elektron::Middlewares::Base
      def call(request_context)
        unless request_context.options[:debug]
          return @next_middleware.call(request_context)
        end
        # Red
        Rails.logger.debug(
          "\033[31m\033[1m########## Cloud Admin Client ##########\033[0m")
        response = @next_middleware.call(request_context)
        response
      end
    end
  end
end