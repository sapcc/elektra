require 'spec_helper'
require_relative '../factories/factories'

describe Automation::RunsController, type: :controller do
  routes { Automation::Engine.routes }

  default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}

  before(:all) do
    FriendlyIdEntry.find_or_create_entry('Domain',nil,default_params[:domain_id],'default')
    FriendlyIdEntry.find_or_create_entry('Project',default_params[:domain_id],default_params[:project_id],default_params[:project_id])
  end

  before :each do
    stub_authentication
    stub_admin_services

    identity_driver = double('identity_service_driver').as_null_object
    compute_driver = double('compute_service_driver').as_null_object
    client = double('ruby_arc_client').as_null_object
    automation_service = double('automation_service').as_null_object
    automation_run_service = double('automation_run_service').as_null_object

    allow_any_instance_of(ServiceLayer::IdentityService).to receive(:driver).and_return(identity_driver)
    allow_any_instance_of(ServiceLayer::ComputeService).to receive(:driver).and_return(compute_driver)
    allow(UserProfile).to receive(:tou_accepted?).and_return(true)
    allow_any_instance_of(ServiceLayer::AutomationService).to receive(:client).and_return(client)
    allow_any_instance_of(ServiceLayer::AutomationService).to receive(:automation_service).and_return(automation_service)
    allow_any_instance_of(ServiceLayer::AutomationService).to receive(:automation_run_service).and_return(automation_run_service)
  end

  describe "GET 'show'" do

    it "returns http success" do
      get :show, default_params.merge(id: 'run_id')
      expect(response).to be_success
      expect(response).to render_template(:show)
    end

  end

  describe "GET 'show_log'" do

    it "returns http success" do
      get :show_log, default_params.merge(id: 'run_id')
      expect(response).to be_success
      expect(response).to render_template(:show_log)
    end

  end

end

