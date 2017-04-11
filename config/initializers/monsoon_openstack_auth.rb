require 'radius/auth'
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
  auth.connection_driver.ssl_verify_peer = Rails.configuration.ssl_verify_peer

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
    :destroy => 'delete',
    :new     => 'create',
    :edit    => 'update'
  }

  # optional, default=false
  auth.debug=auth.debug_api_calls=Rails.configuration.debug_api_calls

  auth.two_factor_authentication_method = -> username,passcode {
    # place here the code to authenticate against a rsa securID Server.
    servers = ENV['TWO_FACTOR_RADIUS_URLS'].split(',')
    secret = ENV['TWO_FACTOR_RADIUS_SECRET']

    # byebug
    servers.each do |server|
      auth = Radius::Auth.new(server, 'localhost', 10) # radius_server, localhost, timeout
      begin
        return (auth.check_passwd(username, passcode, secret))
      rescue => e
        puts "::::::::::::::."
        p e
      end
    end
    return false
  }
end
