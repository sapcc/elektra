require 'spec_helper'
require 'controllers/dashboard/shared_examples'

describe Dashboard::OsImagesController do
  include AuthenticationStub
  
  it_behaves_like "an dashboard controller"

  default_params = {domain_id: AuthenticationStub.domain_id}

  before(:all) do
    DatabaseCleaner.clean
    @domain = create(:domain, key: default_params[:domain_id])
    @project = create(:project, key: default_params[:project_id], domain: @domain)
  end

  before(:each) do
    stub_authentication
    allow_any_instance_of(Openstack::AdminIdentityService).to receive(:new_user?).and_return(false)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index', default_params
      expect(response).to be_success
    end
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new', default_params
      expect(response).to be_success
    end
  end

  describe "POST 'create'" do
    it "returns http success" do
      post 'create', default_params
      expect(response).to be_success
    end
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit', default_params.merge(id:1)
      expect(response).to be_success
    end
  end

  describe "PUT 'update'" do
    it "returns http success" do
      put 'update', default_params.merge(id:1)
      expect(response).to be_success
    end
  end

  describe "DELETE 'destroy'" do
    it "returns http success" do
      delete 'destroy', default_params.merge(id:1)
      expect(response).to be_success
    end
  end
end
