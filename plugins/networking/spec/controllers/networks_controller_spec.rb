require "spec_helper"

describe Networking::Networks::PrivateController, type: :controller do
  routes { Networking::Engine.routes }

  default_params = {
    domain_id: AuthenticationStub.domain_id,
    project_id: AuthenticationStub.project_id,
  }

  before(:all) do
    # DatabaseCleaner.clean
    FriendlyIdEntry.find_or_create_entry(
      "Domain",
      nil,
      default_params[:domain_id],
      "default",
    )
    FriendlyIdEntry.find_or_create_entry(
      "Project",
      default_params[:domain_id],
      default_params[:project_id],
      default_params[:project_id],
    )
  end

  before :each do
    stub_authentication
    allow_any_instance_of(ServiceLayer::NetworkingService).to receive(
      :networks,
    ).and_return []
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, params: default_params
      expect(response).to be_successful
    end
  end
end
