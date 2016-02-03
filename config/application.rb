require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)


module MonsoonDashboard
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    #config.autoload_paths += %W(#{config.root}/plugins)
    config.autoload_paths << Rails.root.join('lib')

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.middleware.insert_before Rack::Sendfile, "DebugEnvMiddleware"
    config.middleware.insert_before Rack::Sendfile, "DebugHeadersMiddleware"
    config.middleware.use "RevisionMiddleware"

    ############# ENSURE EDGE MODE FOR IE ###############
    config.action_dispatch.default_headers["X-UA-Compatible"]="IE=edge,chrome=1"


    ############# KEYSTONE ENDPOINT ##############
    config.keystone_endpoint = if ENV['AUTHORITY_SERVICE_HOST'] && ENV['AUTHORITY_SERVICE_PORT']
            proto = ENV['AUTHORITY_SERVICE_PROTO'] || 'http'
            host  = ENV['AUTHORITY_SERVICE_HOST']
            port  = ENV['AUTHORITY_SERVICE_PORT']
            "#{proto}://#{host}:#{port}/v3"
          else
            ENV['MONSOON_OPENSTACK_AUTH_API_ENDPOINT']
          end

    config.debug_api_calls = true
    ############## REGION ###############
    config.default_region = ENV['MONSOON_DASHBOARD_REGION'] || 'europe'

    #############ä SERVICE USER #############
    config.service_user_id = ENV['MONSOON_OPENSTACK_AUTH_API_USERID']
    config.service_user_password = ENV['MONSOON_OPENSTACK_AUTH_API_PASSWORD']
    config.service_user_domain_name = ENV['MONSOON_OPENSTACK_AUTH_API_DOMAIN']
    config.default_domain = ENV['MONSOON_DASHBOARD_DEFAULT_DOMAIN'] || 'monsoon3'
  end
end
