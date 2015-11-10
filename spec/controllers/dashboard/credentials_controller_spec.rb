require 'spec_helper'

describe Dashboard::CredentialsController, type: :controller do
  
  include AuthenticationStub

  default_params = {domain_id: AuthenticationStub.domain_id}

  before(:all) do
    FriendlyIdEntry.find_or_create_entry('Domain',nil,default_params[:domain_id],'default')
  end

  before(:each) do
    stub_authentication
    
    admin_identity_driver = double('admin_identity_service_driver').as_null_object
    identity_driver = double('identity_service_driver').as_null_object

    allow_any_instance_of(ServiceLayer::AdminIdentityService).to receive(:init) do |admin_identity|
      admin_identity.instance_variable_set(:@driver, admin_identity_driver)
    end
    
    allow_any_instance_of(ServiceLayer::IdentityService).to receive(:init) do |identity|
      identity.instance_variable_set(:@driver, identity_driver)
    end

  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, default_params
      expect(response).to be_success
    end
  end

end
