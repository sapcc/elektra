require 'rails_helper'

RSpec.describe AuthenticatedUser::UsersController, type: :controller do

  describe "GET #terms_of_use" do
    it "returns http success" do
      get :terms_of_use
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #register" do
    it "returns http success" do
      get :register
      expect(response).to have_http_status(:success)
    end
  end

end
