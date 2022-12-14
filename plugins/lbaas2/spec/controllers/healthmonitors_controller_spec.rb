# frozen_string_literal: true

require "spec_helper"
require_relative "./factories/factories.rb"
require_relative "shared"

describe Lbaas2::Loadbalancers::Pools::HealthmonitorsController,
         type: :controller do
  routes { Lbaas2::Engine.routes }

  default_params = {
    domain_id: AuthenticationStub.domain_id,
    project_id: AuthenticationStub.project_id,
    loadbalancer_id: "lb_123456789",
    pool_id: "pool_123456789",
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

  describe "GET 'show'" do
    before :each do
      healthmonitor =
        double(
          "elektron",
          service:
            double(
              "octavia",
              get: double("get", map_to: double("healthmnonitor", to_json: {})),
            ),
        )
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(healthmonitor)
      allow_any_instance_of(
        Lbaas2::Loadbalancers::Pools::HealthmonitorsController,
      ).to receive(:extend_healthmonitor_data).and_return(
        double("healthmonitor").as_null_object,
      )
    end

    it_behaves_like "show action" do
      subject { @default_params = default_params }
    end
  end

  describe "POST 'create'" do
    before :each do
      healthmonitor =
        double(
          "elektron",
          service: double("octavia", post: double("post", body: {})),
        )
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(healthmonitor)
    end

    it_behaves_like "post action" do
      subject do
        @default_params = default_params
        @extra_params = {
          healthmonitor: ::Lbaas2::FakeFactory.new.healthmonitor,
        }
      end
    end
  end

  describe "PUT 'update'" do
    before :each do
      healthmonitor =
        double(
          "elektron",
          service:
            double(
              "octavia",
              get:
                double(
                  "get",
                  map_to: double("healthmnonitor", to_json: {}, update: {}),
                ),
              put: double("put", body: {}),
            ),
        )
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(healthmonitor)
    end

    it_behaves_like "PUT action" do
      subject do
        @default_params = default_params
        healthmonitor = ::Lbaas2::FakeFactory.new.update_healthmonitor
        @extra_params = { id: healthmonitor[:id], healthmonitor: healthmonitor }
      end
    end
  end

  describe "DELETE 'destroy'" do
    before :each do
      healthmonitor =
        double("elektron", service: double("octavia", delete: double("delete")))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(healthmonitor)
    end

    it_behaves_like "destroy action" do
      subject do
        @default_params = default_params
        @extra_params = { id: "healthmonitor_id" }
      end
    end
  end
end
