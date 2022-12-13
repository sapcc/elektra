$sentry_public_dsn =
  URI.parse(ENV["SENTRY_DSN"]).tap { |u| u.password = nil }.to_s if ENV[
  "SENTRY_DSN"
]

Raven.configure do |config|
  # httpclient is the only faraday adpater which handles no_proxy
  config.http_adapter = :httpclient
  config.send_modules = false
  config.app_dirs_pattern = /(app|bin|config|lib|plugins|spec)/
  config.timeout = 3
end

Rails.application.config.assets.precompile += %w[raven.js]

ActiveSupport::Notifications.subscribe(
  "request.active_resource",
) do |name, started, finished, unique_id, data|
  Raven.breadcrumbs.record do |crumb|
    crumb.type = "http"
    crumb.category = "activeresource"
    crumb.data = {
      url: data[:request_uri],
      method: data[:method].to_s.upcase,
      status_code: data[:result].try(:code),
    }
  end
end

#reopen RestClient::Request and inject breadcrumb wrapper
module RestClient
  class Request
    alias_method :original_execute, :execute
    def execute(&block)
      original_execute(&block).tap do |response|
        add_crumb(url, method, response)
      end
    rescue StandardError
      add_crumb(url, method)
      raise
    end

    private

    def add_crumb(url, method, response = nil)
      #puts "add_crumb(#{url}, #{method}, #{response.try(:code)})"
      #return
      Raven.breadcrumbs.record do |crumb|
        crumb.type = "http"
        crumb.category = "rest-client"
        data = { url: url, method: method.to_s.upcase }
        data[:status_code] = response.code if response
        crumb.data = data
      end
    end
  end
end

module Excon
  module Sentry
    class Middleware < Excon::Middleware::Base
      def response_call(datum)
        add_crumb(datum)
        @stack.response_call(datum)
      end

      def error_call(datum)
        add_crumb(datum)
        @stack.error_call(datum)
      end

      private

      def add_crumb(datum)
        Raven.breadcrumbs.record do |crumb|
          crumb.type = "http"
          crumb.category = "excon"
          data = {
            url: Excon::Utils.request_uri(datum),
            method: datum[:method].to_s.upcase,
          }
          data[:status_code] = datum[:response][:status] if datum[:response]
          crumb.data = data
        end
      end
    end
  end
end

Excon.defaults[:middlewares].push Excon::Sentry::Middleware
