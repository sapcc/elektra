# encoding: UTF-8
source 'http://localhost:8080/rubygemsorg/'

gem 'rails', '4.2.0'

# Views and Assets
gem 'compass-rails'
gem 'sass-rails'
gem 'bootstrap-sass'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'haml-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'simple_form'
gem 'redcarpet'
gem 'spinners'

# Database
gem 'pg'
gem 'activerecord-session_store'

# Openstack
gem 'monsoon-fog', git: 'git://localhost/monsoon/monsoon-fog.git'
gem 'fog', git: 'git://localhost/monsoon/fog.git', branch:'master'

gem 'monsoon-openstack-auth', git: 'git://localhost/monsoon/monsoon-openstack-auth.git', branch: :master

# Extras
gem 'rails_config'

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
