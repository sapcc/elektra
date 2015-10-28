require 'spec_helper'

describe Compute::InstancesController, type: :controller do
  routes { Compute::Engine.routes }
  
  include AuthenticationStub
  
  default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}
  
  before(:all) do
    #DatabaseCleaner.clean
    Core::FriendlyIdEntry.find_or_create_entry('Domain',nil,default_params[:domain_id],'default')
    Core::FriendlyIdEntry.find_or_create_entry('Project',default_params[:domain_id],default_params[:project_id],default_params[:project_id])
  end
  
  before :each do
    stub_authentication
    
    admin_identity_driver = double('admin_identity_service_driver').as_null_object
    allow_any_instance_of(Openstack::AdminIdentityService).to receive(:get_driver).and_return(admin_identity_driver)
    
    identity_driver = double('identity_service_driver').as_null_object
    allow_any_instance_of(Openstack::IdentityService).to receive(:get_driver).and_return(identity_driver)
    
    compute_driver = double('compute_service_driver').as_null_object
    allow_any_instance_of(Openstack::ComputeService).to receive(:get_driver).and_return(compute_driver)
    
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, default_params
      expect(response).to be_success
    end
  end

end