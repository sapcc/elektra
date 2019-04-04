require 'spec_helper'

describe Networking::FloatingIpsController, type: :controller do
  routes { Networking::Engine.routes }

  default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}

  before(:all) do
    #DatabaseCleaner.clean
    FriendlyIdEntry.find_or_create_entry('Domain',nil,default_params[:domain_id],'default')
    FriendlyIdEntry.find_or_create_entry('Project',default_params[:domain_id],default_params[:project_id],default_params[:project_id])
  end

  before :each do
    stub_authentication

    @networking_service = double('elektron', service: double('network').as_null_object)

    allow_any_instance_of(ServiceLayer::NetworkingService)
      .to receive(:elektron).and_return(
        double('elektron', service: @networking_service)
      )

    allow_any_instance_of(ServiceLayer::ResourceManagementService)
      .to receive(:quota_data).and_return([])
  end

  describe "GET 'index'" do
    before :each do
      allow(@networking_service).to receive(:get).with('floatingips', anything).and_return(
        double('response', body: {'floatingips' => []})
      )
    end

    it "returns http success" do
      get :index, params: default_params
      expect(response).to be_successful
    end
  end
end
