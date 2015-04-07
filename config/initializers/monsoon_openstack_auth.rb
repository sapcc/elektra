MonsoonOpenstackAuth.configure do |config|
  config.connection_driver.api_endpoint = 'http://localhost:8083/v3/auth/tokens'
  config.connection_driver.api_userid   = 'u-admin'
  config.connection_driver.api_password = 'secret'

  # optional, default=true
  config.token_auth_allowed = true
  # optional, default=true
  config.basic_atuh_allowed = true
  # optional, default=true
  config.sso_auth_allowed   = true
  # optional, default=true
  config.form_auth_allowed  = true

  # optional, default= last url before redirected to form
  #config.login_redirect_url = '/'

  # optional, default=false
  config.debug=true
end
