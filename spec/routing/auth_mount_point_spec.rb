require 'spec_helper'

describe 'auth mount point', type: :routing do
  #routes { MonsoonOpenstackAuth::Engine.routes }

  it "should route '/:domain_fid/auth', :to => 'MonsoonOpenstackAuth'" do
    byebug
    expect(get: '/login',use_route: 'monsoon_openstack_auth').to route_to(
      controller: 'monsoon_openstack_auth/sessions',
      action: 'new',
      domain_fid: 'test_domain'
    )
  end
end
