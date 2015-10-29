require 'spec_helper'

describe DashboardController, type: :controller do
  controller do
    def index
      head :ok
    end
  end
  
  include AuthenticationStub

  default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}

  before(:all) do
    FriendlyIdEntry.find_or_create_entry('Domain',nil,default_params[:domain_id],'default')
    FriendlyIdEntry.find_or_create_entry('Project',default_params[:domain_id],default_params[:project_id],default_params[:project_id])
  end

  before :each do
    stub_authentication

    admin_identity_driver = double('admin_identity_service_driver').as_null_object
    allow_any_instance_of(DomainModel::AdminIdentityService).to receive(:get_driver).and_return(admin_identity_driver)

    identity_driver = double('identity_service_driver').as_null_object
    allow_any_instance_of(DomainModel::IdentityService).to receive(:get_driver).and_return(identity_driver)
    allow(controller).to receive(:_routes).and_return(@routes)
  end


  describe "GET 'index'" do
    it "returns http success" do
      get :index, {domain_id: AuthenticationStub.domain_id}
      expect(response).to be_success
    end
  end

end
