class OpenstackService

  attr_reader :region, :service_catalog, :token

  def initialize(user, region)
    @region           = region
    @service_catalog  = user.service_catalog
    @token            = user.token
  end

  def compute
    @compute ||= Fog::Compute::OpenStack.new(auth_params)
  end

  def identity
    @identity ||= Fog::IdentityV3::OpenStack.new(auth_params)
  end

  def volume
    @volume ||= Fog::Volume::OpenStack.new(auth_params)
  end


  private

  def auth_params
    # project_id = Thread.current[:keystone_token][:project][:id] if Thread.current[:keystone_token][:project]
    # domain_id = Thread.current[:keystone_token][:project][:domain][:id] if Thread.current[:keystone_token][:project]

    # provider: 'openstack',
    # openstack_project_id:project_id,
    # openstack_domain_id:domain_id,

    puts "================================ tok: #{token} ====== auth: #{ENV['MONSOON_OPENSTACK_AUTH_API_ENDPOINT']} ========== region: #{region}"

    {
        provider: 'openstack',
        openstack_auth_token: token,
        openstack_auth_url: ENV['MONSOON_OPENSTACK_AUTH_API_ENDPOINT'],
        openstack_region: region
    }
  end

end
