require 'spec_helper'

RSpec.describe Core::HealthController, type: :controller do
  routes { Core::Engine.routes }
  
  describe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

end
