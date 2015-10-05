require 'spec_helper'


describe Dashboard::ProjectsController do
  include AuthenticationStub

  # commented out for now because the user controller doesn't have an index action and all the shared examples use the index action
  # it_behaves_like "an dashboard controller"
  default_params = {domain_id: AuthenticationStub.domain_id}

  before(:all) do
    DatabaseCleaner.clean
    @domain = create(:domain, key: default_params[:domain_id])
    @project = create(:project, key: default_params[:project_id], domain: @domain)
  end

  before(:each) do
    stub_authentication

    driver = object_spy('driver')
    allow_any_instance_of(Openstack::AdminIdentityService).to receive(:new_user?).and_return(false)
    allow_any_instance_of(Openstack::IdentityService).to receive(:driver).and_return(driver)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, default_params
      expect(response).to be_success
    end
  end

end
