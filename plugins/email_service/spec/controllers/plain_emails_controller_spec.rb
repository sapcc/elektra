require "spec_helper"
require_relative "../factories/factories"

describe EmailService::PlainEmailsController, type: :controller do
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
    allow_any_instance_of(EmailService::PlainEmailsController).to receive(
      :check_pre_conditions_for_cronus,
    ).and_return(double("redirect_path").as_null_object)
    allow_any_instance_of(EmailService::PlainEmailsController).to receive(
      :ses_client_v2,
    ).and_return(double("ses_client_v2").as_null_object)
    allow_any_instance_of(EmailService::PlainEmailsController).to receive(
      :ses_client,
    ).and_return(double("ses_client").as_null_object)
    allow_any_instance_of(EmailService::PlainEmailsController).to receive(
      :check_verified_identity,
    ).and_return(double("render").as_null_object)
    allow_any_instance_of(EmailService::PlainEmailsController).to receive(
      :list_verified_identities,
    ).and_return(double("identities").as_null_object)
    allow_any_instance_of(EmailService::PlainEmailsController).to receive(
      :get_verified_identities_by_status,
    ).and_return(double("statuses").as_null_object)
    allow_any_instance_of(EmailService::PlainEmailsController).to receive(
      :ec2_creds,
    ).and_return(double("creds").as_null_object)
    allow_any_instance_of(EmailService::PlainEmailsController).to receive(
      :send_plain_email,
    ).and_return(double("status").as_null_object)
  end

  # GET new
  describe "GET 'new'" do
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
        get :new, params: default_params
        expect(response).to have_http_status(200)
        expect(response).to render_template(:new)
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
      it "returns http 200 status" do
        get :new, params: default_params
        expect(response).to have_http_status(200)
        expect(response).to render_template(:new)
      end
    end

    context "cloud_support_tools_viewer_role alone" do
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
      it "returns http 401 status" do
        get :new, params: default_params
        expect(response).to render_template(
          'application/exceptions/warning',
        )
      end
    end

    context "other roles" do
      before :each do
        stub_authentication do |token|
          token["roles"].delete_if { |h| h["id"] == "email_service_role" }
          token
        end
      end
      it "not allowed" do
        get :new, params: default_params
        expect(response).to render_template(
          'application/exceptions/warning',
        )
      end
    end
  end

  # POST create
  describe "POST 'create'" do
    before :each do
      @plain_email = ::EmailService::FakeFactory.new.plain_email
      @plain_email_opts = ::EmailService::FakeFactory.new.plain_email_opts
    end

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
        assigns(plain_email: @plain_email)
        post(:create, params: default_params.merge(opts: @plain_email_opts))
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
      it "returns http 200 status" do
        assigns(plain_email: @plain_email)
        post(:create, params: default_params.merge(opts: @plain_email_opts))
        expect(response).to have_http_status(200)
      end
    end

    context "cloud_support_tools_viewer_role alone" do
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
      it "returns http 401 status" do
        expect(
          post(:create, params: default_params.merge(opts: @opts)),
        ).to render_template('application/exceptions/warning')
      end
    end

    context "other roles" do
      before :each do
        stub_authentication do |token|
          token["roles"].delete_if { |h| h["id"] == "email_service_role" }
          token
        end
      end
      it "not allowed" do
        expect(
          post(:create, params: default_params.merge(opts: @opts)),
        ).to render_template('application/exceptions/warning')
      end
    end
  end
end
