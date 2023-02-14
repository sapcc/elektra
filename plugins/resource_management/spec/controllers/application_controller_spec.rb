require "spec_helper"

describe ResourceManagement::DomainAdminController, type: :controller do
  routes { ResourceManagement::Engine.routes }

  default_params = {
    domain_id: AuthenticationStub.domain_id,
    project_id: AuthenticationStub.project_id,
  }

  before(:all) do
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
    stub_authentication do |token|
      # domain admin
      token["roles"] << { "id" => "2", "name" => "admin" }
      token["roles"] << { "id" => "resource_role", "name" => "resource_viewer" }
      token["domain"] = { "id" => "1", "name" => "default" }
      token
    end
    allow_any_instance_of(ServiceLayer::ResourceManagementService).to receive(
      :find_domain,
    ).and_return(double("domain").as_null_object)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, params: default_params
      expect(response).to be_successful
    end
  end
end
