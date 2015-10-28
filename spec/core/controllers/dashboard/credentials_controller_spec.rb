require 'spec_helper'

describe Core::Dashboard::CredentialsController, type: :controller do
  routes { Core::Engine.routes }
  
  include AuthenticationStub

  default_params = {domain_id: AuthenticationStub.domain_id}

  before(:all) do
    Core::FriendlyIdEntry.find_or_create_entry('Domain',nil,default_params[:domain_id],'default')
  end

  before(:each) do
    stub_authentication
    
    admin_identity_driver = double('admin_identity_service_driver').as_null_object
    allow_any_instance_of(Openstack::AdminIdentityService).to receive(:get_driver).and_return(admin_identity_driver)
    
    identity_driver = double('identity_service_driver').as_null_object
    allow_any_instance_of(Openstack::IdentityService).to receive(:get_driver).and_return(identity_driver)
    
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, default_params
      expect(response).to be_success
    end
  end

end
