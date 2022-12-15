require "spec_helper"

RSpec.describe HealthController, type: :controller do
  describe "GET #liveliness" do
    it "returns http success" do
      get :liveliness
      expect(response).to have_http_status(:success)
    end
    it "returns http success" do
      get :readiness
      expect(response).to have_http_status(:success)
    end
  end
end
