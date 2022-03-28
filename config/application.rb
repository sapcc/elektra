require_relative 'boot'

require 'rails/all'

# Require core functionalities
require_relative File.expand_path('../lib/core', __dir__)
# Require middlewares due to loading bug in Rails 5.1
require_relative File.expand_path('../app/middleware/middlewares', __dir__)
# Require sassc custom functions
require_relative File.expand_path('../lib/sassc', __dir__)

require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MonsoonDashboard
  class Application < Rails::Application
    config.load_defaults 6.1
    config.react.addons = true

    config.hosts << /.*\.cloud\.sap/
    
    def self.module_parent_name
      super 
    end

    def self.parent_name 
      self.module_parent_name
    end 

    # commented out due to error seen in prod:
    # Cannot render console from 10.XX.XX.XX! Allowed networks: XX.XX.XX.XX, ...
    # config.web_console.development_only = false

    # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
    # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
    config.require_master_key = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # config.autoload_paths += %W(#{config.root}/plugins)

    # config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths << "#{Rails.root}/lib"
    

    # Use memory for caching, file cache needs some work for working with docker
    # Not sure if this really makes sense becasue every passenger thread will have it's own cache
    config.cache_store = :memory_store

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.action_cable.mount_path = '/:domain_id/(:project_id)/cable'

    config.middleware.insert_before Rack::Sendfile, DebugHeadersMiddleware

    # build a map from the plugins
    plugin_mount_points = {}
    Core::PluginsManager.available_plugins.each { |plugin| plugin_mount_points[plugin.mount_point] = plugin.mount_point }

    # rack middlewares
    config.middleware.use HttpMetricsMiddleware
    config.middleware.use InquiryMetricsMiddleware
    config.middleware.use SLIMetricsMiddleware
    config.middleware.use Prometheus::Middleware::Exporter
    config.middleware.use RevisionMiddleware

    ############# ENSURE EDGE MODE FOR IE ###############
    config.action_dispatch.default_headers['X-UA-Compatible'] = 'IE=edge,chrome=1'

    ############# KEYSTONE ENDPOINT ##############
    config.keystone_endpoint = if ENV['AUTHORITY_SERVICE_HOST'] && ENV['AUTHORITY_SERVICE_PORT']
                                 proto = ENV['AUTHORITY_SERVICE_PROTO'] || 'http'
                                 host  = ENV['AUTHORITY_SERVICE_HOST']
                                 port  = ENV['AUTHORITY_SERVICE_PORT']
                                 "#{proto}://#{host}:#{port}/v3"
                               else
                                 ENV['MONSOON_OPENSTACK_AUTH_API_ENDPOINT']
          end

    config.debug_api_calls = ENV.key?('DEBUG_API_CALLS')
    config.debug_policy_engine = ENV.key?('DEBUG_POLICY_ENGINE')

    config.ssl_verify_peer = true
    Excon.defaults[:ssl_verify_peer] = true
    if ENV.key?('ELEKTRA_SSL_VERIFY_PEER') && (ENV['ELEKTRA_SSL_VERIFY_PEER'] == 'false')
      config.ssl_verify_peer = false
      # set ssl_verify_peer for Excon that is used in FOG to talk with openstack services
      Excon.defaults[:ssl_verify_peer] = false
    end
    puts "=> SSL verify: #{config.ssl_verify_peer}"

    ############## REGION ###############
    config.default_region = ENV['MONSOON_DASHBOARD_REGION'] || ['eu-de-1', 'staging', 'europe']

    ############## CLOUD ADMIN ###############
    config.cloud_admin_domain = ENV.fetch('MONSOON_OPENSTACK_CLOUDADMIN_DOMAIN', 'ccadmin')
    config.cloud_admin_project = ENV.fetch('MONSOON_OPENSTACK_CLOUDADMIN_PROJECT', 'cloud_admin')

    ############## SERVICE USER #############
    config.service_user_id = ENV['MONSOON_OPENSTACK_AUTH_API_USERID']
    config.service_user_password = ENV['MONSOON_OPENSTACK_AUTH_API_PASSWORD']
    config.service_user_domain_name = ENV['MONSOON_OPENSTACK_AUTH_API_DOMAIN']
    config.default_domain = ENV['MONSOON_DASHBOARD_DEFAULT_DOMAIN'] || 'monsoon3'

    # Mailer configuration for inquiries/requests
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV['MONSOON_DASHBOARD_MAIL_SERVER'],
      port: ENV['MONSOON_DASHBOARD_MAIL_SERVER_PORT'] || 25,
      enable_starttls_auto: false
    }
    config.action_mailer.default_options = {
      from: 'Converged Cloud <noreply+ConvergedCloud@sap.corp>'
    }

    config.middleware.use SessionCookiePathMiddleware
    config.middleware.insert_after ::Rack::Runtime, SameSiteCookieMiddleware
    config.middleware.insert_after ::Rack::Runtime, SecureCookies

  end
end
