require "spec_helper"

describe AccessProfile::TagsController, type: :controller do
  routes { AccessProfile::Engine.routes }

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

  describe "GET 'index'" do
    before :each do
      @existing_tags = %w[
        xs:internet:keppel_account_pull:test1
        xs:internet:keppel_account_pull:test2
      ]
      allow(controller.cloud_admin).to receive(:list_tags).and_return(
        @existing_tags,
      )
    end

    context "QA regions" do
      before :each do
        Rails.configuration.default_region = "qa-de-1"
      end

      context "just project_admin" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token["roles"] << {
              "id" => "project_admin_role",
              "name" => "admin",
            }
            token
          end
        end
        it "returns http success" do
          get :index, params: default_params.merge({})
          expect(response).to be_successful
        end
      end

      context "empty roles" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token
          end
        end
        it "returns http success" do
          get :index, params: default_params.merge({})
          expect(response).to_not be_successful
        end
      end
    end

    context "PROD regions" do
      before :each do
        Rails.configuration.default_region = "eu-de-1"
      end

      context "project_admin and cloud_support_tools_viewer" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token["roles"] << {
              "id" => "project_admin_role",
              "name" => "admin",
            }
            token["roles"] << {
              "id" => "cloud_support_tools_viewer",
              "name" => "cloud_support_tools_viewer",
            }
            token
          end
        end
        it "returns http success" do
          get :index, params: default_params.merge({})
          expect(response).to be_successful
        end
      end

      context "project_admin" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token["roles"] << {
              "id" => "project_admin_role",
              "name" => "admin",
            }
            token
          end
        end
        it "returns http success" do
          get :index, params: default_params.merge({})
          expect(response).to_not be_successful
        end
      end

      context "empty roles" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token
          end
        end
        it "returns http success" do
          get :index, params: default_params.merge({})
          expect(response).to_not be_successful
        end
      end
    end
  end

  describe "PUT 'create a tag'" do
    context "QA regions" do
      before :each do
        Rails.configuration.default_region = "qa-de-1"
      end

      context "project_admin" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token["roles"] << {
              "id" => "project_admin_role",
              "name" => "admin",
            }
            # token['roles'] << { 'id' => 'cloud_support_tools_viewer', 'name' => 'cloud_support_tools_viewer' }
            token
          end
        end
        it "returns http success" do
          post :create,
               params:
                 default_params.merge(
                   { tag: "xs:internet:keppel_account_pull:cc-demo" },
                 )
          expect(response).to be_successful
        end
      end

      context "empty roles" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token
          end
        end
        it "returns http success" do
          post :create,
               params:
                 default_params.merge(
                   { tag: "xs:internet:keppel_account_pull:cc-demo" },
                 )
          expect(response).to_not be_successful
        end
      end
    end

    context "PROD regions" do
      before :each do
        Rails.configuration.default_region = "eu-de-1"
      end

      context "project_admin and cloud_support_tools_viewer" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token["roles"] << {
              "id" => "project_admin_role",
              "name" => "admin",
            }
            token["roles"] << {
              "id" => "cloud_support_tools_viewer",
              "name" => "cloud_support_tools_viewer",
            }
            token
          end
        end
        it "returns http success" do
          post :create,
               params:
                 default_params.merge(
                   { tag: "xs:internet:keppel_account_pull:cc-demo" },
                 )
          expect(response).to be_successful
        end
      end

      context "just project_admin" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token["roles"] << {
              "id" => "project_admin_role",
              "name" => "admin",
            }
            token
          end
        end
        it "returns http success" do
          post :create,
               params:
                 default_params.merge(
                   { tag: "xs:internet:keppel_account_pull:cc-demo" },
                 )
          expect(response).to_not be_successful
        end
      end

      context "empty roles" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token
          end
        end
        it "returns http success" do
          post :create,
               params:
                 default_params.merge(
                   { tag: "xs:internet:keppel_account_pull:cc-demo" },
                 )
          expect(response).to_not be_successful
        end
      end
    end

    context "base prefixes" do
      before :each do
        Rails.configuration.default_region = "qa-de-1"
        stub_authentication do |token|
          token["roles"] = []
          token["roles"] << { "id" => "project_admin_role", "name" => "admin" }
          token
        end
      end

      it "adds base prefix/tag" do
        identity = double("identity", list_tags: [])
        cloud_admin = double("cloud_admin", identity: identity).as_null_object
        new_tags = []
        allow(identity).to receive(:add_single_tag) do |_scoped_project_id, tag|
          new_tags.push(tag)
        end
        allow_any_instance_of(::ApplicationController).to receive(
          :cloud_admin,
        ).and_return(cloud_admin)

        post :create,
             params:
               default_params.merge(
                 { tag: "xs:internet:keppel_account_pull:cc-demo" },
               )
        expect(
          new_tags.include?("xs:internet:keppel_account_pull:cc-demo"),
        ).to be true
        expect(new_tags.include?("xs:internet")).to be true
      end

      it "no adds base prefix/tag if already exists" do
        identity = double("identity", list_tags: ["xs:internet"])
        cloud_admin = double("cloud_admin", identity: identity).as_null_object
        new_tags = []
        allow(identity).to receive(:add_single_tag) do |_scoped_project_id, tag|
          new_tags.push(tag)
        end
        allow_any_instance_of(::ApplicationController).to receive(
          :cloud_admin,
        ).and_return(cloud_admin)

        post :create,
             params:
               default_params.merge(
                 { tag: "xs:internet:keppel_account_pull:cc-demo" },
               )
        expect(
          new_tags.include?("xs:internet:keppel_account_pull:cc-demo"),
        ).to be true
        expect(new_tags.include?("xs:internet")).to_not be true
        expect(new_tags.length).to eq(1)
      end
    end

    context "validation" do
      before :each do
        stub_authentication do |token|
          Rails.configuration.default_region = "qa-de-1"
          token["roles"] = []
          token["roles"] << { "id" => "project_admin_role", "name" => "admin" }
          token
        end
        @existing_tag = "xs:internet:keppel_account_pull:d063222"
        allow(controller.cloud_admin).to receive(:list_tags).and_return(
          [@existing_tag],
        )
      end

      it "returns http error if no tag given" do
        post :create, params: default_params.merge({})
        expect(response).to_not be_successful
      end
      it "returns http success using profile and service with required variable" do
        post :create,
             params:
               default_params.merge(
                 { tag: "xs:internet:keppel_account_pull:cc-demo" },
               )
        expect(response).to be_successful
      end
      it "returns http error using profile and service without required variable" do
        post :create,
             params:
               default_params.merge({ tag: "xs:internet:keppel_account_pull" })
        expect(response).to_not be_successful
      end
      it "returns http error using profile and service with number of variable mistmacht" do
        post :create,
             params:
               default_params.merge(
                 { tag: "xs:internet:keppel_account_pull:cc-demo:blabla" },
               )
        expect(response).to_not be_successful
      end
      it "returns http success using profile and service" do
        post :create,
             params: default_params.merge({ tag: "xs:internet:dns_reader" })
        expect(response).to be_successful
      end
      it "returns http error using profile and service and not required variable" do
        post :create,
             params:
               default_params.merge({ tag: "xs:internet:dns:reader:test" })
        expect(response).to_not be_successful
      end
      it "returns http error using just the profile name" do
        post :create, params: default_params.merge({ tag: "xs:internet" })
        expect(response).to_not be_successful
      end
      it "returns http error if tag already exists" do
        post :create, params: default_params.merge({ tag: @existing_tag })
        expect(response).to_not be_successful
      end
    end
  end

  describe "DELETE 'tag'" do
    before :each do
      @existing_tag = "xs:internet:keppel_account_pull:d063222"
      allow(controller.cloud_admin).to receive(:list_tags).and_return(
        [@existing_tag],
      )
      allow(controller.cloud_admin).to receive(:remove_single_tag).and_return(
        "succeed",
      )
    end

    context "QA regions" do
      before :each do
        Rails.configuration.default_region = "qa-de-1"
      end

      context "just project_admin" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token["roles"] << {
              "id" => "project_admin_role",
              "name" => "admin",
            }
            token
          end
        end
        it "returns http success" do
          delete :destroy,
                 params:
                   default_params.merge(
                     { id: "xs:internet:keppel_account_pull:d063222" },
                   )
          expect(response).to be_successful
        end
      end

      context "empty roles" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token
          end
        end
        it "returns http success" do
          delete :destroy,
                 params:
                   default_params.merge(
                     { id: "xs:internet:keppel_account_pull:d063222" },
                   )
          expect(response).to_not be_successful
        end
      end
    end

    context "PROD regions" do
      before :each do
        Rails.configuration.default_region = "eu-de-1"
      end

      context "project_admin and cloud_support_tools_viewer" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token["roles"] << {
              "id" => "project_admin_role",
              "name" => "admin",
            }
            token["roles"] << {
              "id" => "cloud_support_tools_viewer",
              "name" => "cloud_support_tools_viewer",
            }
            token
          end
        end
        it "returns http success" do
          delete :destroy,
                 params:
                   default_params.merge(
                     { id: "xs:internet:keppel_account_pull:d063222" },
                   )
          expect(response).to be_successful
        end
      end

      context "just project_admin" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token["roles"] << {
              "id" => "project_admin_role",
              "name" => "admin",
            }
            token
          end
        end
        it "returns http success" do
          delete :destroy,
                 params:
                   default_params.merge(
                     { id: "xs:internet:keppel_account_pull:d063222" },
                   )
          expect(response).to_not be_successful
        end
      end

      context "empty roles" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token
          end
        end
        it "returns http success" do
          delete :destroy,
                 params:
                   default_params.merge(
                     { id: "xs:internet:keppel_account_pull:d063222" },
                   )
          expect(response).to_not be_successful
        end
      end
    end

    context "remove action" do
      before :each do
        stub_authentication do |token|
          Rails.configuration.default_region = "qa-de-1"
          token["roles"] = []
          token["roles"] << { "id" => "project_admin_role", "name" => "admin" }
          token
        end
      end

      it "removes base prefix/tag" do
        all_tags = %w[xs:internet xs:internet:keppel_account_pull:cc-demo]
        identity = double("identity", list_tags: all_tags)
        cloud_admin = double("cloud_admin", identity: identity).as_null_object
        allow(identity).to receive(
          :remove_single_tag,
        ) do |_scoped_project_id, tag|
          all_tags.delete_if { |x| x == tag }
        end
        allow_any_instance_of(::ApplicationController).to receive(
          :cloud_admin,
        ).and_return(cloud_admin)

        delete :destroy,
               params:
                 default_params.merge(
                   { id: "xs:internet:keppel_account_pull:cc-demo" },
                 )
        expect(
          all_tags.include?("xs:internet:keppel_account_pull:cc-demo"),
        ).to be false
        expect(all_tags.include?("xs:internet")).to be false
        expect(all_tags.length).to eq(0)
      end

      it "keeps base prefix/tag" do
        all_tags = %w[
          xs:internet
          xs:internet:keppel_account_pull:cc-demo
          xs:internet:keppel_account_pull:miau
        ]
        identity = double("identity", list_tags: all_tags)
        cloud_admin = double("cloud_admin", identity: identity).as_null_object
        allow(identity).to receive(
          :remove_single_tag,
        ) do |_scoped_project_id, tag|
          all_tags.delete_if { |x| x == tag }
        end
        allow_any_instance_of(::ApplicationController).to receive(
          :cloud_admin,
        ).and_return(cloud_admin)

        delete :destroy,
               params:
                 default_params.merge(
                   { id: "xs:internet:keppel_account_pull:cc-demo" },
                 )
        expect(
          all_tags.include?("xs:internet:keppel_account_pull:cc-demo"),
        ).to be false
        expect(all_tags.include?("xs:internet")).to be true
        expect(all_tags.length).to eq(2)
      end
    end

    context "validation" do
      before :each do
        stub_authentication do |token|
          Rails.configuration.default_region = "qa-de-1"
          token["roles"] = []
          token["roles"] << { "id" => "project_admin_role", "name" => "admin" }
          token
        end
      end

      it "returns http error if no tag given" do
        delete :destroy, params: default_params.merge({ id: "" })
        expect(response).to_not be_successful
      end

      it "returns http error if no tag no valid" do
        delete :destroy,
               params:
                 default_params.merge(
                   { id: "xs:internet:non_existing_service:d063222" },
                 )
        expect(response).to_not be_successful
      end

      it "returns succeed with an existing tag which matches the config" do
        delete :destroy,
               params:
                 default_params.merge(
                   { id: "xs:internet:keppel_account_pull:d063222" },
                 )
        expect(response).to be_successful
      end
    end
  end

  describe "get 'profiles_config'" do
    context "QA regions" do
      before :each do
        Rails.configuration.default_region = "qa-de-1"
      end

      context "just project_admin" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token["roles"] << {
              "id" => "project_admin_role",
              "name" => "admin",
            }
            # token['roles'] << { 'id' => 'cloud_support_tools_viewer', 'name' => 'cloud_support_tools_viewer' }
            token
          end
        end
        it "returns http success" do
          get :profiles_config, params: default_params.merge({})
          expect(response).to be_successful
        end
      end

      context "empty roles" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token
          end
        end
        it "returns http success" do
          get :profiles_config, params: default_params.merge({})
          expect(response).to_not be_successful
        end
      end
    end

    context "PROD regions" do
      before :each do
        Rails.configuration.default_region = "eu-de-1"
      end

      context "project_admin and cloud_support_tools_viewer" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token["roles"] << {
              "id" => "project_admin_role",
              "name" => "admin",
            }
            token["roles"] << {
              "id" => "cloud_support_tools_viewer",
              "name" => "cloud_support_tools_viewer",
            }
            token
          end
        end
        it "returns http success" do
          get :profiles_config, params: default_params.merge({})
          expect(response).to be_successful
        end
      end

      context "just project_admin" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token["roles"] << {
              "id" => "project_admin_role",
              "name" => "admin",
            }
            token
          end
        end
        it "returns http success" do
          get :profiles_config, params: default_params.merge({})
          expect(response).to_not be_successful
        end
      end

      context "empty roles" do
        before :each do
          stub_authentication do |token|
            token["roles"] = []
            token
          end
        end
        it "returns http success" do
          get :profiles_config, params: default_params.merge({})
          expect(response).to_not be_successful
        end
      end
    end
  end
end
