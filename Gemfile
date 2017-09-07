# encoding: UTF-8
source 'https://rubygems.org'

# Avoid g++ dependency https://github.com/knu/ruby-domain_name/issues/3
# # unf is pulled in by the ruby-arc-client
gem 'unf', '>= 0.2.0beta2'

# Don't use 5.1.3 because of redirect errors in tests
# (scriptr vs. script name in ActionPack)
gem 'rails', '5.1.2'

# Views and Assets
gem 'bootstrap-sass'
gem 'coffee-rails'
gem 'compass-rails'
gem 'font-awesome-sass'
gem 'friendly_id'
gem 'haml-rails'
gem 'high_voltage'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'redcarpet'
gem 'sass-rails'
gem 'sass_inline_svg', git: 'https://github.com/tlesmann/sass-inline-svg.git',
                       branch: :master
gem 'simple-navigation' # Navigation menu builder
gem 'simple_form'
gem 'spinners'
gem 'uglifier'

gem 'responders'

# make it fancy with react
gem 'react-rails'

# Database
gem 'activerecord-session_store'
gem 'pg'

# Openstack
gem 'fog-openstack', git: 'https://github.com/sapcc/fog-openstack.git',
                     branch: :master
gem 'net-ssh'
gem 'netaddr'
# gem 'fog-openstack', path: '../fog-openstack', branch: :master
gem 'fog-openstack-sap-billing',
    git: 'https://github.com/sapcc/fog-openstack-sap-billing.git',
    branch: :master

# gem 'monsoon-openstack-auth',
#     git: 'https://github.com/sapcc/monsoon-openstack-auth.git'
gem 'monsoon-openstack-auth', path: '../monsoon-openstack-auth'

gem 'ruby-radius'

# Extras
gem 'config'

# Prometheus instrumentation
gem 'prometheus-client'

# Sentry client
gem 'httpclient' # The only faraday backend that handled no_proxy :|
gem 'sentry-raven'

# Automation
gem 'arc-client', git: 'https://github.com/sapcc/arc-client.git'
gem 'lyra-client', git: 'https://github.com/sapcc/lyra-client.git'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Limes
gem 'misty', git: 'https://github.com/flystack/misty.git', branch: :master
# gem 'misty', git: 'https://github.com/sapcc/misty.git', branch: 'thread-safe-requests'
# gem 'misty', path: '../misty'
gem 'misty-cc', git: 'https://github.com/sapcc/misty-cc.git'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'puma', require: false
###################### PLUGINS #####################

# backlist plugins (global)
# e.g. ['compute', 'cost_control']
black_list = %w[webconsole kubernetes]
if ENV.key?('BLACK_LIST_PLUGINS')
  ENV['BLACK_LIST_PLUGINS'].split(',').each do |plugin_name|
    black_list << plugin_name.strip
  end
end

# load all plugins except blacklisted plugins
Dir.glob('plugins/*').each do |plugin_path|
  unless black_list.include?(plugin_path.gsub('plugins/', ''))
    gemspec path: plugin_path
  end
end

######################## END #######################

# Avoid double log lines in development
# See: https://github.com/heroku/rails_stdout_logging/issues/1
group :production do
  # We are not using the railtie because it comes to late,
  # we are setting the logger in production.rb
  gem 'rails_stdout_logging', require: 'rails_stdout_logging/rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.0'
  # gem 'quiet_assets' #can be removed once we upgraded to sprockets >=3.1.0
end

group :development, :test do
  # load .env.bak needed for cucumber tests!
  gem 'dotenv-rails'
  gem 'foreman'

  # Call 'byebug' anywhere in the code to stop execution and get a
  # debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Testing
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'pry-rails'
  gem 'rspec'
  gem 'rspec-rails'
end

group :integration_tests do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'cucumber-rails', require: false
  gem 'phantomjs', require: false
  gem 'poltergeist'
end

group :test do
  gem 'guard-rspec'
  gem 'rails-controller-testing'
end

# load dotenv to get ENV for extension retrieval if needed
begin
  require 'dotenv'
  Dotenv.load
rescue Exception => e
  puts e
end

# load SAP specific extension for fonts, ....
if ENV['ELEKTRA_EXTENSION'].to_s == 'true'
  gem 'elektra-extension',
      git: 'git://github.wdf.sap.corp/monsoon/elektra-extension.git',
      branch: :master
end
