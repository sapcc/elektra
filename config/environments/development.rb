$stdout.sync = true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are skip migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # better error and web_console is only working when you accessing from localhost
  # if you running the development server on a remote machine use TRUSTED_IP
  # for that take a look to the .env and set the variable or run "TRUSTED_IP=192.168.1.1 forman start"
  if ENV['TRUSTED_IP']
    # to use better errors not only on localhost
    BetterErrors::Middleware.allow_ip! ENV['TRUSTED_IP']
    # use web_console not only on localhost
    config.web_console.whitelisted_ips = ENV['TRUSTED_IP']
    puts "=> Trusted IP #{ENV['TRUSTED_IP']}"
  end

  # Mailer configuration
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address:              'localhost',
      port:                 25,
      enable_starttls_auto: false }
  config.action_mailer.default_options = {
      from: 'do.not.reply@sap.com'
  }
  config.action_mailer.perform_deliveries = true

  puts "=> Auth Endpoint #{ENV['MONSOON_OPENSTACK_AUTH_API_ENDPOINT']}" if ENV['MONSOON_OPENSTACK_AUTH_API_ENDPOINT']

end
