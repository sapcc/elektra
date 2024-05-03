# frozen_string_literal: true

require "spec_helper"

describe ScopeController, type: :controller do
  controller do
    def index
      head :ok
    end
  end

  default_params = {
    domain_id: AuthenticationStub.domain_id,
    project_id: AuthenticationStub.project_id,
  }

  before(:all) do
    @domain_friendly_id =
      FriendlyIdEntry.find_or_create_entry(
        "Domain",
        nil,
        default_params[:domain_id],
        "default 1",
      )
    @project_friendly_id =
      FriendlyIdEntry.find_or_create_entry(
        "Project",
        default_params[:domain_id],
        default_params[:project_id],
        "project 1",
      )
  end

  before :each do
    stub_authentication
  end

  context "domain_id is provided, project_id is not provided" do
    describe "GET index" do
      it "returns http success" do
        get :index, params: { domain_id: @domain_friendly_id.slug }
        expect(response).to be_successful
      end

      it "redirects to the same action with friendly ids for domain" do
        get :index,
            params: {
              domain_id: AuthenticationStub.domain_id,
              project_id: nil,
            }
        expect(response).to redirect_to("/#{@domain_friendly_id.slug}/scope")
      end

      it "redirects to the same action with friendly ids for domain and other parameters" do
        get :index,
            params: {
              domain_id: AuthenticationStub.domain_id,
              name: "test",
            }
        expect(response).to redirect_to(
          "/#{@domain_friendly_id.slug}/scope?name=test",
        )
      end


    end
  end

  context "domain_id and project_id are provided" do
    describe "GET index" do
      it "returns http success" do
        get :index,
            params: {
              domain_id: @domain_friendly_id.slug,
              project_id: @project_friendly_id.slug,
            }
        expect(response).to be_successful
      end
    end
  end

  context "bedrock" do 
    before :each do 
      test_config = {
        "domains" => [
          {
            "name" => "test domain",
            "regex" => "^#{@domain_friendly_id.name}$",
            "disabled_plugins" => ["compute", "networking"]
          }
        ]
      }
      BedrockConfig.class_variable_set(:@@bedrock_config_file, test_config)
    end
    it "test the @bedrock_config is set" do
      get :index, params: { domain_id: @domain_friendly_id.slug }
      expect(assigns(:bedrock_config)).to be_a_kind_of(BedrockConfig)
    end

    it "should redirect to error-404" do
      allow(controller).to receive(:plugin_name).and_return("compute")
      get :index, params: { domain_id: @domain_friendly_id.slug, project_id: @project_friendly_id.slug}
      expect(response).to redirect_to("/error-404")
    end


    it "should not redirect to error-404" do
      allow(controller).to receive(:plugin_name).and_return("some-other-plugin")
      get :index, params: { domain_id: @domain_friendly_id.slug, project_id: @project_friendly_id.slug}
      expect(response).not_to redirect_to("/error-404")
    end
  end
end
