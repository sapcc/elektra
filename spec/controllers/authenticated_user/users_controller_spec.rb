require 'spec_helper'

describe AuthenticatedUser::UsersController, type: :controller do
  include AuthenticationStub
  
  default_params = {domain_id: AuthenticationStub.domain_id}

  before(:each) do
    stub_authentication  
  end
  
  describe "GET #new" do
    it "returns http success" do
      get :new, default_params
      expect(response).to have_http_status(:success)
    end
  end

  # describe "POST #create" do
  #   it "returns http success" do
  #     post :create
  #     expect(response).to have_http_status(:success)
  #   end
  # end
end
