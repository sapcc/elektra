# You need to allow webpack-dev-server host as allowed origin for connect-src.
# This can be done in Rails 5.2+ for development environment in the CSP initializer
# config/initializers/content_security_policy.rb with a snippet like this:
# https://github.com/rails/webpacker#development
# You need to allow webpack-dev-server host as allowed origin for connect-src.
# This can be done in Rails 5.2+ for development environment in the CSP initializer
# config/initializers/content_security_policy.rb
domains = ["*.cloud.sap"]

if Rails.env.development?
domains.concat([
  "http://0.0.0.0:8081", 
  "ws://0.0.0.0:8081", 
  "http://localhost:8081",
  "ws://localhost:8081",
  ])
end
  
Rails.application.config.content_security_policy do |policy|
#  policy.connect_src :self, :https, *domains
#  policy.img_src     :self, :https, :data, "*"

  # policy.default_src :self, :https, *domains
  # policy.font_src :self, :https, :data, "*"
  # policy.object_src :none
  # policy.script_src :self, :https, "*" 
  # policy.style_src :self, :https, :unsafe_inline
end