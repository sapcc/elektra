require 'elektron'

module ElektronMiddlewares
  class PrettyDebugUser < Elektron::Middlewares::Base
    def call(request_context)
      unless request_context.options[:debug]
        return @next_middleware.call(request_context)
      end
      # Green
      Rails.logger.debug("\033[32m\033[1m################ Elektron: User " \
                         "Client, #{request_context.service_name} ########"\
                         "#####\033[22m")
      response = @next_middleware.call(request_context)
      Rails.logger.debug("\033[0m")
      response
    end
  end

  class PrettyDebugServiceUser < Elektron::Middlewares::Base
    def call(request_context)
      unless request_context.options[:debug]
        return @next_middleware.call(request_context)
      end
      # Blue
      Rails.logger.debug("\033[34m\033[1m################ Elektron: Service "\
                         "User Client, #{request_context.service_name} "\
                         "#############\033[22m")
      response = @next_middleware.call(request_context)
      Rails.logger.debug("\033[0m")
      response
    end
  end

  class PrettyDebugCloudAdmin < Elektron::Middlewares::Base
    def call(request_context)
      unless request_context.options[:debug]
        return @next_middleware.call(request_context)
      end
      # Red
      Rails.logger.debug("\033[31m\033[1m################ Elektron: Cloud "\
                         "Admin Client, #{request_context.service_name} "\
                         "#############\033[22m")
      response = @next_middleware.call(request_context)
      Rails.logger.debug("\033[0m")
      response
    end
  end
end
