require 'spec_helper'
require_relative '../factories/factories'

describe KeyManager::ContainersController, type: :controller do
  routes { KeyManager::Engine.routes }

  default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}

  before(:all) do
    FriendlyIdEntry.find_or_create_entry('Domain',nil,default_params[:domain_id],'default')
    FriendlyIdEntry.find_or_create_entry('Project',default_params[:domain_id],default_params[:project_id],default_params[:project_id])
  end

  before :each do
    stub_authentication

    keymanager_service = double('keymanager_service').as_null_object

    allow_any_instance_of(ServiceLayer::KeyManagerService).to receive(:service).and_return(keymanager_service)
    allow(UserProfile).to receive(:tou_accepted?).and_return(true)
  end

  describe "GET 'index'" do

    before :each do
      allow_any_instance_of(ServiceLayer::KeyManagerService).to receive(:containers).and_return({elements: [::KeyManager::FakeFactory.new.container], total_elements: 1})
    end

    it "returns http success and renders the right template" do
      get :index, default_params
      expect(response).to be_success
      expect(response).to render_template(:index)
    end

  end

  describe "GET 'show'" do

    before :each do
      @container = ::KeyManager::FakeFactory.new.container(container_ref: "https://keymanager-app/v1/containers/5492647f-eb4f-4ff7-b923-b59a6ce73f69")
      allow_any_instance_of(ServiceLayer::KeyManagerService).to receive(:container).and_return(@container)
    end

    it "returns http success and renders the right template" do
      get :show, default_params.merge({id: @container.uuid})
      expect(response).to be_success
      expect(response).to render_template(:show)
    end

  end

  describe "GET 'new'" do

    it "returns http success and renders the right template" do
      get :new, default_params
      expect(response).to be_success
      expect(response).to render_template(:new)
    end

  end

  describe "GET 'create'" do

    it "returns http success and renders the new template if validation fails" do
      post :create, default_params
      expect(response).to be_success
      expect(response).to render_template(:new)
    end

    it "returns http success and redirects to index if validation is valid" do
      mock_container = double('mock_container').as_null_object
      allow_any_instance_of(ServiceLayer::KeyManagerService).to receive(:new_container).and_return(mock_container)
      allow(mock_container).to receive(:save).and_return(true)
      allow(mock_container).to receive(:valid?).and_return(true)

      post :create, default_params.merge({container: ::KeyManager::FakeFactory.new.container.attributes})
      expect(response).to redirect_to(containers_path(default_params))
    end

  end

  describe "GET 'destroy'" do

    it "returns http success and renders view" do
      delete :destroy, default_params.merge({id: 'container_id'})
      expect(response).to be_success
      expect(response).to render_template(:index)
    end

  end

end
