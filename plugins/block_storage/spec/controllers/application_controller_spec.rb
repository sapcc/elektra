require "spec_helper"

describe BlockStorage::ApplicationController, type: :controller do
=begin
  routes { BlockStorage::Engine.routes }
  
  
  
  default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}
  
  before(:all) do
    FriendlyIdEntry.find_or_create_entry('Domain',nil,default_params[:domain_id],'default')
    FriendlyIdEntry.find_or_create_entry('Project',default_params[:domain_id],default_params[:project_id],default_params[:project_id])
  end
  
  before :each do
    stub_authentication
    stub_admin_services
    
    identity_driver = double('identity_service_driver').as_null_object
    
    allow_any_instance_of(ServiceLayer::IdentityService).to receive(:driver).and_return(identity_driver)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, default_params
      expect(response).to be_successful
    end
  end
=end
end
