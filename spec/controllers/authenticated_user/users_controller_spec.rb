require 'spec_helper'

# require 'controllers/authenticated_user/shared_examples'

describe AuthenticatedUser::UsersController do
  include AuthenticationStub

  # commented out for now because the user controller doesn't have an index action and all the shared examples use the index action
  # it_behaves_like "an authenticated_user controller"
  default_params = {domain_fid: AuthenticationStub.domain_id}

  before(:all) do
    DatabaseCleaner.clean
    @domain = create(:domain, key: default_params[:domain_fid])
    @project = create(:project, key: default_params[:project_fid], domain: @domain)
  end

  before(:each) do
    stub_authentication

    driver = object_spy('driver')
    allow_any_instance_of(Openstack::AdminIdentityService).to receive(:service_user).and_return(driver)
  end

  describe "GET 'new'" do
    it "returns http success" do
      get :new, default_params
      expect(response).to be_success
    end
  end
  # describe "POST #create" do
  #   it "returns http success" do
  #     post :create
  #     expect(response).to have_http_status(:success)
  #   end
  # end
end
