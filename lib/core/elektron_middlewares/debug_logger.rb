require 'elektron'

module ElektronMiddlewares
  class DebugLogger < Elektron::Middlewares::Base

    def call(request_context)
      debug = request_context.options.delete(:debug)
      response = @next_middleware.call(request_context)

      return response unless debug

      path = URI(URI.escape(request_context.path))
      if request_context.params && !request_context.path.empty?
        path.query = URI.encode_www_form(request_context.params)
      end

      output = ''
      output += "\033[1;36mElektron #{request_context.service_name} " \
                "(#{request_context.options[:region]}/" \
                "#{request_context.options[:interface]}):\n"
      output += "\033[1;34m-> #{request_context.http_method.upcase} " \
                "#{request_context.service_url}#{path}\n"

      unless request_context.options[:headers].empty?
        output += "-> headers: #{request_context.options[:headers]}\n"
      end

      output += "-> body: #{request_context.data}\n" if request_context.data

      output += "\033[1;34m<- #{response.header.class.name}"
      output += "\n<- body:  #{response.body}" if response.body
      output += "\033[0m"

      Rails.logger.debug(output)
      response
    end
  end
end
