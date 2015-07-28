require 'spec_helper'

require 'controllers/authenticated_user/shared_examples'

describe AuthenticatedUser::CredentialsController do
  include AuthenticationStub

  it_behaves_like "an authenticated_user controller"

  default_params = {domain_id: AuthenticationStub.domain_id}

  before(:all) do
    DatabaseCleaner.clean
    @domain = create(:domain, key: default_params[:domain_id])
  end

  before(:each) do
    stub_authentication
    allow_any_instance_of(Openstack::AdminIdentityService).to receive(:new_user?).and_return(false)
    driver = object_spy('driver')
    allow_any_instance_of(Openstack::IdentityService).to receive(:driver).and_return(driver)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, default_params
      expect(response).to be_success
    end
  end

  # describe "GET 'new'" do
  #   it "returns http success" do
  #     get :new, default_params
  #     expect(response).to be_success
  #   end
  # end

end
