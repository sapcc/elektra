MonsoonOpenstackAuth.configure do |config|
  # connection driver, default MonsoonOpenstackAuth::Driver::Default (Fog)
  # config.connection_driver = DriverClass
  config.connection_driver.api_endpoint = ("http://#{ENV['AUTHORITY_SERVICE_HOST']}:#{ENV['AUTHORITY_SERVICE_PORT']}" if ENV['AUTHORITY_SERVICE_HOST'] && ENV['AUTHORITY_SERVICE_PORT']) || ENV['MONSOON_OPENSTACK_AUTH_API_ENDPOINT']
  config.connection_driver.api_userid   = ENV['MONSOON_OPENSTACK_AUTH_API_USERID']
  config.connection_driver.api_password = ENV['MONSOON_OPENSTACK_AUTH_API_PASSWORD']

  # optional, default=true
  config.token_auth_allowed = true
  # optional, default=true
  config.basic_auth_allowed = true
  # optional, default=true
  config.sso_auth_allowed   = true
  # optional, default=true
  config.form_auth_allowed  = true
  
  # optional, default=false
  config.access_key_auth_allowed = false

  # optional, default= last url before redirected to form
  #config.login_redirect_url = '/'

  # authorization policy file
  config.authorization.policy_file_path = "config/policy_test.json"
  config.authorization.context = "identity"
  
  # optional, default=false
  config.debug=true
end
