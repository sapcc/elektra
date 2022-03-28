require 'elektron'

module Core
  module ElektronMiddlewares
    class UserLogger < Elektron::Middlewares::Base
      def call(request_context)
        unless request_context.options[:debug]
          return @next_middleware.call(request_context)
        end

        # Green
        Rails.logger.debug(
          "\033[32m\033[1m########## User Client ##########\033[0m"
        )
        response = @next_middleware.call(request_context)
        response
      end
    end
  end
end
