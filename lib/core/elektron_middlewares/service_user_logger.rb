require "elektron"

module Core
  module ElektronMiddlewares
    class ServiceUserLogger < Elektron::Middlewares::Base
      def call(request_context)
        unless request_context.options[:debug]
          return @next_middleware.call(request_context)
        end
        # Blue
        Rails.logger.debug(
          "\033[33m\033[1m########## Service User Client ##########\033[0m",
        )
        response = @next_middleware.call(request_context)
        response
      end
    end
  end
end
