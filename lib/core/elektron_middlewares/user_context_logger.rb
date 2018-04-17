require 'elektron'

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

  class ServiceUserLogger < Elektron::Middlewares::Base
    def call(request_context)
      unless request_context.options[:debug]
        return @next_middleware.call(request_context)
      end
      # Blue
      Rails.logger.debug(
        "\033[33m\033[1m########## Service User Client ##########\033[0m"
      )
      response = @next_middleware.call(request_context)
      response
    end
  end

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
