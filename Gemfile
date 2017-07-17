# encoding: UTF-8
source 'https://rubygems.org'

# Avoid g++ dependency https://github.com/knu/ruby-domain_name/issues/3
# # unf is pulled in by the ruby-arc-client
gem 'unf', '>= 0.2.0beta2'

gem 'rails', '4.2.4'

# Views and Assets
gem 'compass-rails'
gem 'sass-rails'
gem 'bootstrap-sass'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'haml-rails'
gem 'simple_form'
gem 'redcarpet'
gem 'spinners'
gem 'sass_inline_svg'
gem 'friendly_id'
gem 'high_voltage'
gem 'simple-navigation' # Navigation menu builder
gem 'font-awesome-sass'

gem 'responders'

# make it fancy with react
gem 'react-rails'

# Database
gem 'pg'
gem 'activerecord-session_store'

# Openstack
gem 'net-ssh'
gem 'netaddr'
gem 'fog-openstack', git: 'https://github.com/sapcc/fog-openstack.git', branch: :master
#gem 'fog-openstack', path: '../fog-openstack', branch: :master
gem 'fog-openstack-sap-billing', git: 'https://github.com/sapcc/fog-openstack-sap-billing.git', branch: :master

gem 'monsoon-openstack-auth', git: 'https://github.com/sapcc/monsoon-openstack-auth.git'
#gem 'monsoon-openstack-auth', path: '../monsoon-openstack-auth'

gem 'ruby-radius'

# Extras
gem 'config'

# Prometheus instrumentation
gem 'prometheus-client'

# Sentry client
gem 'sentry-raven'
gem 'httpclient' # The only faraday backend that handled no_proxy :|

# Automation
gem 'lyra-client', git: 'https://github.com/sapcc/lyra-client.git'
gem 'arc-client', git: 'https://github.com/sapcc/arc-client.git'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Limes
gem 'misty', git: 'https://github.com/flystack/misty.git', branch: :master
# gem 'misty', git: 'https://github.com/sapcc/misty.git', branch: 'update-neutron'
gem 'misty-limes', git: 'https://github.com/sapcc/misty-limes.git'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'puma', require: false
###################### PLUGINS #####################

# backlist plugins (global)
black_list = ['webconsole'] #e.g. ['compute', 'cost_control']
if ENV.has_key?('BLACK_LIST_PLUGINS')
  ENV['BLACK_LIST_PLUGINS'].split(',').each{|plugin_name| black_list << plugin_name.strip}
end

# load all plugins except blacklisted plugins
Dir.glob("plugins/*").each do |plugin_path|
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
  gem 'web-console', '~> 2.0'

  gem 'quiet_assets' #can be removed once we upgraded to sprockets >=3.1.0
end

group :development, :test do

  # load .env.bak needed for cucumber tests!
  gem 'dotenv-rails'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem "foreman"

  # Testing
  gem "rspec"
  gem "rspec-rails"
  gem "factory_girl_rails", "~> 4.0"
  gem "database_cleaner"

  gem 'pry-rails'
end

group :integration_tests do
  gem "capybara"
  gem 'capybara-screenshot'
  gem "cucumber-rails", require: false
  gem 'phantomjs', require: false
  gem 'poltergeist'
end

group :test do
  gem 'guard-rspec'
end

# load dotenv to get ENV for extension retrieval if needed
begin
  require 'dotenv'
  Dotenv.load
rescue Exception => e
end

# load SAP specific extension for fonts, ....
if ENV['ELEKTRA_EXTENSION'].to_s == 'true'
  gem 'elektra-extension', git: "git://github.wdf.sap.corp/monsoon/elektra-extension.git", branch: :master
end
