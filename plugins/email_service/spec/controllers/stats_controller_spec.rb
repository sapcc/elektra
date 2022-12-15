require "spec_helper"
require_relative "../factories/factories"

describe EmailService::StatsController, type: :controller do
  routes { EmailService::Engine.routes }

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
    allow(UserProfile).to receive(:tou_accepted?).and_return(true)
    allow_any_instance_of(EmailService::StatsController).to receive(
      :check_ec2_creds_cronus_status,
    ).and_return(double("redirect_path").as_null_object)
    allow_any_instance_of(EmailService::StatsController).to receive(
      :check_verified_identity,
    ).and_return(double("render").as_null_object)
    allow_any_instance_of(EmailService::StatsController).to receive(
      :ec2_creds,
    ).and_return(double("creds").as_null_object)
    allow_any_instance_of(EmailService::StatsController).to receive(
      :ses_client_v2,
    ).and_return(double("ses_client_v2").as_null_object)
    allow_any_instance_of(EmailService::StatsController).to receive(
      :ses_client,
    ).and_return(double("ses_client").as_null_object)
  end

  describe "GET 'index'" do
    context "email_admin" do
      before :each do
        stub_authentication do |token|
          token["roles"] = []
          token["roles"] << {
            "id" => "email_service_role",
            "name" => "email_admin",
          }
          token["roles"] << {
            "id" => "cloud_support_tools_viewer_role",
            "name" => "cloud_support_tools_viewer",
          }
          token
        end
      end
      it "returns http 200 status" do
        get :index, params: default_params
        expect(response).to have_http_status(200)
      end
    end

    context "email_user" do
      before :each do
        stub_authentication do |token|
          token["roles"] = []
          token["roles"] << {
            "id" => "email_service_role",
            "name" => "email_user",
          }
          token["roles"] << {
            "id" => "cloud_support_tools_viewer_role",
            "name" => "cloud_support_tools_viewer",
          }
          token
        end
      end
      it "returns http success" do
        get :index, params: default_params
        expect(response).to be_successful
      end
    end

    context "only cloud_support_tools_viewer_role" do
      before :each do
        stub_authentication do |token|
          token["roles"] = []
          token["roles"] << {
            "id" => "cloud_support_tools_viewer_role",
            "name" => "cloud_support_tools_viewer",
          }
          token
        end
      end
      it "returns http status 401" do
        get :index, params: default_params
        expect(response).to render_template(
          "application/exceptions/warning.html",
        )
      end
    end
  end
end
