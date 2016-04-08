def policy_paths
  paths = ["config/policy.json"]
  Core::PluginsManager.available_plugins.each do |p|
    paths << p.policy_file_path if p.has_policy_file?
  end
  paths
end


MonsoonOpenstackAuth.configure do |auth|
  # connection driver, default MonsoonOpenstackAuth::Driver::Default (Fog)
  # auth.connection_driver = DriverClass
    
  auth.connection_driver.api_endpoint = Rails.application.config.keystone_endpoint
  auth.connection_driver.ssl_verify_peer = false

  # optional, default=true
  auth.token_auth_allowed = true
  # optional, default=true
  auth.basic_auth_allowed = true
  # optional, default=true
  auth.sso_auth_allowed   = true
  # optional, default=true
  auth.form_auth_allowed  = true

  # optional, default=false
  auth.access_key_auth_allowed = false

  # optional, default= last url before redirected to form
  #auth.login_redirect_url = -> referrer_url, current_user { after_login_url(referrer_url, current_user)}
  auth.login_redirect_url = -> referrer_url, current_user do 
    # redirect user to domain home page after login
    if referrer_url.blank? or (!(referrer_url=~/^[^\?]*#{current_user.user_domain_name}/) and !(referrer_url=~/^[^\?]*#{current_user.user_domain_id}/))
      "/#{current_user.user_domain_id}/identity/home"
    else
      referrer_url
    end
    #referrer_url.blank? ? "/#{current_user.user_domain_id}/identity/home" : referrer_url
  end

  # authorization policy file
  auth.authorization.policy_file_path = policy_paths
  # auth.authorization.context = "identity"
  auth.authorization.context = "identity"


  #auth.authorization.trace_enabled = true
  auth.authorization.reload_policy = Rails.configuration.debug_policy_engine
  auth.authorization.trace_enabled = Rails.configuration.debug_policy_engine

  auth.authorization.controller_action_map = {
    :index   => 'list',
    :show    => 'get',
    :destroy => 'delete'
  }

  # optional, default=false
  auth.debug=auth.debug_api_calls=Rails.configuration.debug_api_calls
end

