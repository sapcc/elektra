require 'rails_helper'

RSpec.describe Dashboard::NetworksController, type: :controller do

  describe "GET #index,show,new,create,edit,update,destroy" do
    it "returns http success" do
      get :index,show,new,create,edit,update,destroy
      expect(response).to have_http_status(:success)
    end
  end

end
