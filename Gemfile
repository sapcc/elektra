# encoding: UTF-8
source 'http://localhost:8080/rubygemsorg/'
source 'https://localhost/' do
  gem 'ruby-arc-client', '~> 0.2.0'
end

gem 'rails', '4.2.4'

# Views and Assets
gem 'compass-rails'
gem 'sass-rails'
gem 'bootstrap-sass'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
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

# Database
gem 'pg'
gem 'activerecord-session_store'

# Openstack
gem 'monsoon-fog', git: 'git://localhost/monsoon/monsoon-fog.git', :ref => '52f4b2'
gem 'fog', git: 'git://localhost/monsoon/fog.git', branch:'master', :ref => 'b3c62'

gem 'monsoon-openstack-auth', git: 'git://localhost/monsoon/monsoon-openstack-auth.git', branch: :master
#gem 'monsoon-openstack-auth', path: '../monsoon-openstack-auth'

gem 'converged_cloud_bootstrap', git: 'git://localhost/monsoon/converged_cloud_bootstrap.git'
#gem 'converged_cloud_bootstrap', path: '../converged_cloud_bootstrap'

# Extras
gem 'config'


###################### PLUGINS ####################
# backlist plugins 
black_list = [] #e.g. ['compute']

Dir.glob("plugins/*").each do |plugin_path|
  unless black_list.include?(plugin_path.gsub('plugins/',''))
    gemspec path: plugin_path
  end
end
######################## END ##########################


# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby


# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # load .env
  gem 'dotenv-rails'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem "foreman"

  # Testing
  gem "rspec"
  gem "rspec-rails"
  gem "factory_girl_rails", "~> 4.0"
  gem "cucumber-rails", require: false
  gem "capybara"
  gem "database_cleaner"
  #gem 'phantomjs'

  gem 'poltergeist'
  gem 'phantomjs', :require => 'phantomjs/poltergeist'
  gem 'capybara-screenshot'


  gem "better_errors"
  gem 'pry-rails'
end

group :test do
  gem 'guard-rspec'
end