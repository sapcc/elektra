def after_login_url(current_user)
  region = MonsoonOpenstackAuth.configuration.default_region
  
  url = if current_user.project_id
    domain = ::Domain.friendly_find_or_create region, current_user.project_domain_id
    project = ::Project.friendly_find_or_create region, domain, current_user.project_id
    
    "/#{domain.slug}/#{project.slug}/projects/#{project.slug}"
  elsif current_user.domain_id
    domain = ::Domain.friendly_find_or_create region, current_user.domain_id
    
    "/#{domain.slug}"
  else
    "/"
  end
rescue
  "/"
end

MonsoonOpenstackAuth.configure do |config|
  # connection driver, default MonsoonOpenstackAuth::Driver::Default (Fog)
  # config.connection_driver = DriverClass
  config.connection_driver.api_endpoint = ("http://#{ENV['AUTHORITY_SERVICE_HOST']}:#{ENV['AUTHORITY_SERVICE_PORT']}/v3/auth/tokens" if ENV['AUTHORITY_SERVICE_HOST'] && ENV['AUTHORITY_SERVICE_PORT']) || ENV['MONSOON_OPENSTACK_AUTH_API_ENDPOINT']
  config.connection_driver.api_userid   = ENV['MONSOON_OPENSTACK_AUTH_API_USERID']
  config.connection_driver.api_domain   = ENV['MONSOON_OPENSTACK_AUTH_API_DOMAIN']
  config.connection_driver.api_password = ENV['MONSOON_OPENSTACK_AUTH_API_PASSWORD']
  config.connection_driver.ssl_verify_peer = false

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
  
  config.default_region = ENV['MONSOON_DASHBOARD_REGION'] || 'europe'
  
  # optional, default=sap_default
  config.default_domain_name = 'sap_default'

  # optional, default= last url before redirected to form
  config.login_redirect_url = -> current_user { after_login_url(current_user)}

  # authorization policy file
  config.authorization.policy_file_path = "config/policy.json"
  config.authorization.context = "identity"
  
  #config.authorization.trace_enabled = true
  config.authorization.reload_policy = true
  config.authorization.trace_enabled = true
  
  config.authorization.controller_action_map = {
    :index   => 'list',
    :show    => 'get',
    :destroy => 'delete'
  }
  
  # optional, default=false
  config.debug=true
end

