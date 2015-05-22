require 'spec_helper'
require 'controllers/authenticated_user/shared_examples'

describe AuthenticatedUser::ImagesController do
  include AuthenticationStub
  
  it_behaves_like "an authenticated_user controller"

  default_params = {domain_id: AuthenticationStub.domain_id}

  before(:each) do
    stub_authentication
    allow_any_instance_of(TechnicalUser).to receive(:sandbox_exists?).and_return(true)
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
