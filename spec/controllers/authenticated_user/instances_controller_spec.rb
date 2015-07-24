require 'spec_helper'
require 'controllers/authenticated_user/shared_examples'

describe AuthenticatedUser::InstancesController do
  include AuthenticationStub
  
  it_behaves_like "an authenticated_user controller"
  default_params = {domain_fid: AuthenticationStub.domain_id}

  before(:all) do
    DatabaseCleaner.clean
    @domain = create(:domain, key: default_params[:domain_fid])
    @project = create(:project, key: default_params[:project_fid], domain: @domain)
  end


  before(:each) do
    stub_authentication  

    driver = object_spy('driver')
    allow_any_instance_of(Openstack::AdminIdentityService).to receive(:new_user?).and_return(false)
    allow_any_instance_of(Openstack::IdentityService).to receive(:driver).and_return(driver)    
    allow_any_instance_of(Openstack::ComputeService).to receive(:driver).and_return(driver)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, default_params
      expect(response).to be_success
    end
  end

end
