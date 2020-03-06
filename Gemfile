source 'https://rubygems.org'

# https://bundler.io/v1.5/gemfile.html
# https://guides.rubygems.org/patterns/#semantic-versioning
# Note: check Dockerfile for Version dependencies!
#       Because we install gems with native extension before running bundle install
#       This avoids recompiling them everytime the Gemfile.lock changes.
#       The versions need to be kept in sync with the Gemfile.lock

# Avoid g++ dependency https://github.com/knu/ruby-domain_name/issues/3
# # unf is pulled in by the ruby-arc-client
gem 'unf', '0.2.0beta2' # pinned in Dockerfile

gem 'rails', '~> 5.2.3' # Don't use 5.1.3 because of redirect errors in tests (scriptr vs. script name in ActionPack)
gem 'webpacker', '~> 4.0'

# Views and Assets
gem 'compass-rails', '3.0.2'
gem 'sass-rails', '5.0.6'
gem 'bootstrap-sass', '3.4.1'
gem 'uglifier', '4.1.19'
gem 'coffee-rails', '4.2.2'
gem 'jquery-rails', '4.3.1'
gem 'jquery-ui-rails', '6.0.1'
gem 'haml-rails', '1.0.0'
gem 'simple_form', '5.0.1'
gem 'redcarpet', '3.4.0' # pinned in Dockerfile
gem 'spinners', '1.1.0'
gem 'sass_inline_svg', '0.0.7'
gem 'friendly_id', '5.2.1'
gem 'high_voltage','3.0.0'
gem 'simple-navigation','4.0.5'
gem 'font-awesome-sass','4.7.0'

gem 'responders','2.4.0'

# make it fancy with react
gem 'react-rails', '~> 2.2.1'

# Database
gem 'pg', '0.21.0' # pinned in Dockerfile
gem 'activerecord-session_store','1.1.3'

# Openstack
gem 'net-ssh','4.1.0'
gem 'netaddr', '2.0.4'

gem 'monsoon-openstack-auth', git: 'https://github.com/sapcc/monsoon-openstack-auth.git'
# gem 'monsoon-openstack-auth', path: '../monsoon-openstack-auth'
gem 'colorize','0.8.1'

gem 'ruby-radius', '1.1'

# Extras
gem 'config', '1.4.0'

# Prometheus instrumentation
gem 'prometheus-client', '0.9.0'

# Sentry client
gem 'sentry-raven', '2.6.3'
gem 'httpclient', '2.8.3'

# Automation
gem 'lyra-client', git: 'https://github.com/sapcc/lyra-client.git'
gem 'arc-client', git: 'https://github.com/sapcc/arc-client.git'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 1.0.0', group: :doc

gem 'puma', "3.12.4" , require: false # pinned in Dockerfile
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
  gem 'elektron', git: 'https://github.com/sapcc/elektron', tag: 'v2.2.0'
  # gem 'elektron', path: '../elektron'
end

# Avoid double log lines in development
# See: https://github.com/heroku/rails_stdout_logging/issues/1
group :production do
  # We are not using the railtie because it comes to late,
  # we are setting the logger in production.rb
  gem 'rails_stdout_logging', require: 'rails_stdout_logging/rails'
end

# Access an IRB console on exception pages or by using <%= console %> in views
gem 'web-console', '~> 3.0'

group :development, :test do
  # load .env.bak needed for cucumber tests!
  gem 'dotenv-rails', '2.6.0'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '9.0.6' # pinned in Dockerfile

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring','2.0.2'

  gem 'foreman', '~> 0.87.0'

  # Testing

  gem 'rspec-rails', '3.6.1'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'database_cleaner', '1.6.1'
  gem 'pry-rails', '0.3.6'
end

group :development, :test, :integration_tests do
  gem 'rspec', '3.6.0'
end

group :integration_tests do
  gem 'capybara', '2.18.0'
  gem 'capybara-screenshot', '1.0.21'
  gem 'cucumber-rails', '1.6.0', require: false
  gem 'phantomjs', '2.1.1.0',  require: false
  gem 'poltergeist', '1.16.0'
end

group :test do
  gem 'guard-rspec','4.7.3'
  gem 'rails-controller-testing','1.0.2'
end
