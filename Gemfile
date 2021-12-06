source 'https://rubygems.org'

# https://bundler.io/v1.5/gemfile.html
# https://guides.rubygems.org/patterns/#semantic-versioning
# Note: check Dockerfile for Version dependencies!
#       Because we install gems with native extension before running bundle install
#       This avoids recompiling them everytime the Gemfile.lock changes.
#       The versions need to be kept in sync with the Gemfile.lock

# Avoid g++ dependency https://github.com/knu/ruby-domain_name/issues/3
# # unf is pulled in by the ruby-arc-client
gem 'unf', '>= 0.2.0beta2'

gem 'rails', '~> 5.2.5' # Don't use 5.1.3 because of redirect errors in tests (scriptr vs. script name in ActionPack)
gem 'webpacker', '~> 4.0' # Check package.json -> "@rails/webpacker"

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
gem 'kaminari', '~> 1.2.1'

gem 'responders'

# make it fancy with react
gem 'react-rails', '~> 2.2.1'

# Database
gem 'pg'
gem 'activerecord-session_store'

# Openstack
gem 'net-ssh'
gem 'netaddr', '2.0.4'

gem 'monsoon-openstack-auth', git: 'https://github.com/sapcc/monsoon-openstack-auth.git'
# gem 'monsoon-openstack-auth', path: '../monsoon-openstack-auth'
gem 'colorize'

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

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 1.1.0', group: :doc

# if you update puma check Dockerfile for Version dependencies!
gem 'puma', '= 4.3.9', require: false
###################### PLUGINS #####################

# backlist plugins (global)
black_list = %w[bare_metal_hana] # e.g. ['compute']
if ENV.key?('BLACK_LIST_PLUGINS')
  ENV['BLACK_LIST_PLUGINS'].split(',').each { |plugin_name| black_list << plugin_name.strip }
end

# load all plugins except blacklisted plugins
Dir.glob('plugins/*').each do |plugin_path|
  unless black_list.include?(plugin_path.gsub('plugins/', ''))
    gemspec path: plugin_path
  end
end

######################## END #######################

group :api_client do
  gem 'elektron', git: 'https://github.com/sapcc/elektron', tag: 'v2.2.1'
  # gem 'elektron', path: '../elektron'
end

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
end

group :development, :test do
  # load .env.bak needed for cucumber tests!
  gem 'dotenv-rails'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'foreman', '~> 0.87.0'

  # Testing

  gem 'rspec-rails'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'database_cleaner'

  gem 'pry-rails'
  gem 'prettier'
end

group :development, :test, :integration_tests do
  gem 'rspec'
  gem 'colorize' #needs to be here otherwise the tests will break
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
