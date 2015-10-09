def after_login_url(referrer_url, current_user)
  redirect_to_sandbox = if referrer_url
    path = URI(referrer_url).path rescue nil
    path.nil? ? true : path.count('/') < 3
  else
    true
  end

  sandbox_url = if (redirect_to_sandbox and current_user.project_id)
    "/#{current_user.project_domain_id}/#{current_user.project_id}/projects"
  else
    nil
  end
  domain_url = "/#{current_user.domain_id}" if current_user.domain_id

  sandbox_url || referrer_url || domain_url || "/"

rescue
  referrer_url || "/"
end

MonsoonOpenstackAuth.configure do |config|
  # connection driver, default MonsoonOpenstackAuth::Driver::Default (Fog)
  # config.connection_driver = DriverClass

  config.connection_driver.api_endpoint = if ENV['AUTHORITY_SERVICE_HOST'] && ENV['AUTHORITY_SERVICE_PORT']
                                            proto = ENV['AUTHORITY_SERVICE_PROTO'] || 'http'
                                            host  = ENV['AUTHORITY_SERVICE_HOST']
                                            port  = ENV['AUTHORITY_SERVICE_PORT']
                                            "#{proto}://#{host}:#{port}/v3/auth/tokens"
                                          else
                                            ENV['MONSOON_OPENSTACK_AUTH_API_ENDPOINT']
                                          end
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
  config.login_redirect_url = -> referrer_url, current_user { after_login_url(referrer_url, current_user)}

  # authorization policy file
  config.authorization.policy_file_path = "config/policy.json"
  config.authorization.context = "identity"

  #config.authorization.trace_enabled = true
  config.authorization.reload_policy = false
  config.authorization.trace_enabled = false

  config.authorization.controller_action_map = {
    :index   => 'list',
    :show    => 'get',
    :destroy => 'delete'
  }

  # optional, default=false
  config.debug=true
end
