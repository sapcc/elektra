# frozen_string_literal: true

require "spec_helper"

describe Lookup::ServicesController, type: :controller do
  controller do
    def index
      head :ok
    end
  end

  routes { Lookup::Engine.routes }

  default_params = {
    domain_id: AuthenticationStub.domain_id,
    project_id: AuthenticationStub.project_id,
  }

  before(:all) do
    # DatabaseCleaner.clean
    @domain_friendly_id_entry =
      FriendlyIdEntry.find_or_create_entry(
        "Domain",
        nil,
        default_params[:domain_id],
        "default",
      )
    @project_friendly_id_entry =
      FriendlyIdEntry.find_or_create_entry(
        "Project",
        default_params[:domain_id],
        default_params[:project_id],
        default_params[:project_id],
      )
  end

  before :each do
    stub_authentication
    allow(UserProfile).to receive(:tou_accepted?).and_return true
    Lookup::ServicesController.send(
      :public,
      *Lookup::ServicesController.protected_instance_methods,
    )
  end

  shared_examples_for "a lookup service" do |service_method_map|
    service_method_map.values.each do |service_data|
      service_name = service_data.first
      method_name = service_data.last

      context "service #{service_name}" do
        it "should find service" do
          object_service = controller.object_service(service_name)
          expect(object_service).not_to be(nil)
        end

        it "should respond to method name" do
          object_service = controller.object_service(service_name)
          expect(object_service).to respond_to(method_name.to_sym)
        end
      end
    end
  end

  describe "object_service" do
    context "domain scope" do
      map = Lookup::ServicesController::DOMAIN_SERVICE_METHOD_MAP
      it_should_behave_like "a lookup service", map
    end

    context "project scope" do
      map = Lookup::ServicesController::PROJECT_SERVICE_METHOD_MAP
      it_should_behave_like "a lookup service", map
    end
  end
end
