# frozen_string_literal: true

require "spec_helper"
require_relative "./factories/factories.rb"
require_relative "shared"

describe Lbaas2::LoadbalancersController, type: :controller do
  routes { Lbaas2::Engine.routes }

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
      lbs =
        double(
          "elektron",
          service: double("octavia", get: double("get", map_to: [])),
        )
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(lbs)
      allow_any_instance_of(Lbaas2::LoadbalancersController).to receive(
        :extend_lb_data,
      ).and_return(double("lbaas").as_null_object)
    end

    it_behaves_like "index action" do
      subject { @default_params = default_params }
    end
  end

  describe "GET 'show'" do
    before :each do
      lbs =
        double(
          "elektron",
          service:
            double(
              "octavia",
              get: double("get", map_to: double("lb", to_json: {})),
            ),
        )
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(lbs)
      allow_any_instance_of(Lbaas2::LoadbalancersController).to receive(
        :extend_lb_data,
      ).and_return(double("lbaas").as_null_object)
    end

    it_behaves_like "show action" do
      subject { @default_params = default_params }
    end
  end

  describe "POST 'create'" do
    before :each do
      lbs =
        double(
          "elektron",
          service: double("octavia", post: double("post", body: {})),
        )
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(lbs)
      allow_any_instance_of(Lbaas2::LoadbalancersController).to receive(
        :extend_lb_data,
      ).and_return(double("lbaas").as_null_object)
    end

    it_behaves_like "post action" do
      subject do
        @default_params = default_params
        @extra_params = { loadbalancer: ::Lbaas2::FakeFactory.new.loadbalancer }
      end
    end
  end

  describe "PUT 'update'" do
    before :each do
      loadbalancer =
        double(
          "elektron",
          service:
            double(
              "octavia",
              get:
                double(
                  "get",
                  map_to: double("loadbalancer", to_json: {}, update: {}),
                ),
              put: double("put", body: {}),
            ),
        )
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(loadbalancer)
      allow_any_instance_of(Lbaas2::LoadbalancersController).to receive(
        :extend_lb_data,
      ).and_return(double("lbaas").as_null_object)
    end

    it_behaves_like "PUT action" do
      subject do
        @default_params = default_params
        loadbalancer = ::Lbaas2::FakeFactory.new.update_loadbalancer
        @extra_params = { id: loadbalancer[:id], loadbalancer: loadbalancer }
      end
    end
  end

  describe "DELETE 'destroy'" do
    before :each do
      lbs =
        double("elektron", service: double("octavia", delete: double("delete")))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(lbs)
    end

    it_behaves_like "destroy action" do
      subject do
        @default_params = default_params
        @extra_params = { id: "lb_id" }
      end
    end
  end

  describe "GET 'device'" do
    before :each do
      lbs =
        double(
          "elektron",
          service: double("octavia", get: double("get", body: { amphora: {} })),
        )
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(lbs)
    end

    it_behaves_like "GET action with cloud_network_admin rule" do
      subject do
        @default_params = default_params
        @extra_params = { id: "lb_id" }
        @path = "device"
      end
    end
  end

  describe "GET 'status_tree'" do
    before :each do
      lbs =
        double(
          "elektron",
          service:
            double(
              "octavia",
              get: double("get", map_to: double("status_tree", to_json: {})),
            ),
        )
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(lbs)
      allow_any_instance_of(Lbaas2::LoadbalancersController).to receive(
        :extend_lb_data,
      ).and_return(double("lbaas").as_null_object)
    end

    it_behaves_like "GET action with viewer context" do
      subject do
        @default_params = default_params
        @extra_params = { id: "lb_id" }
        @path = "status_tree"
      end
    end
  end

  describe "PUT 'attach_fip'" do
    before :each do
      lb =
        double(
          "lb",
          :to_json => {
          },
          :vip_port_id => "12345",
          :floating_ip= => true,
        )
      lbs =
        double(
          "elektron",
          service: double("octavia", get: double("get", map_to: lb)),
        )
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(lbs)
      allow_any_instance_of(Lbaas2::LoadbalancersController).to receive(
        :extend_lb_data,
      ).and_return(double("lbaas").as_null_object)
      allow_any_instance_of(ServiceLayer::NetworkingService).to receive(
        :new_floating_ip,
      ).and_return(double("floating_ip").as_null_object)
    end

    it_behaves_like "PUT action" do
      subject do
        @action = "attach_fip"
        @default_params = default_params
        @extra_params = { id: "123456789", floating_ip: "qwertyuiop" }
      end
    end
  end

  describe "PUT 'detach_fip'" do
    before :each do
      lbs =
        double(
          "elektron",
          service:
            double(
              "octavia",
              get: double("get", map_to: double("lb", to_json: {})),
            ),
        )
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(lbs)
      allow_any_instance_of(Lbaas2::LoadbalancersController).to receive(
        :extend_lb_data,
      ).and_return(double("lbaas").as_null_object)
      allow_any_instance_of(ServiceLayer::NetworkingService).to receive(
        :detach_floatingip,
      ).and_return(double("floating_ip").as_null_object)
    end

    it_behaves_like "PUT action" do
      subject do
        @action = "detach_fip"
        @default_params = default_params
        @extra_params = { id: "123456789", floating_ip: "qwertyuiop" }
      end
    end
  end

  describe "GET 'private_networks'" do
    before :each do
      allow_any_instance_of(ServiceLayer::NetworkingService).to receive(
        :project_networks,
      ).and_return([])
    end

    it_behaves_like "GET action with editor context" do
      subject do
        @default_params = default_params
        @extra_params = { id: "lb_id" }
        @path = "private_networks"
      end
    end
  end

  describe "GET 'subnets'" do
    before :each do
      allow_any_instance_of(ServiceLayer::NetworkingService).to receive(
        :find_network!,
      ).and_return(double("private_network", subnet_objects: nil))
    end

    it_behaves_like "GET action with editor context" do
      subject do
        @default_params = default_params
        @extra_params = { id: "lb_id" }
        @path = "subnets"
      end
    end
  end

  describe "GET 'availability_zones'" do
    before :each do
      @avs = [
        { "name" => "qa-de-1a", "enabled" => true },
        { "name" => "qa-de-1b", "enabled" => false },
      ]
      elektron =
        double(
          "elektron",
          service:
            double(
              "octavia",
              get: double("response", body: double("body", fetch: @avs)),
            ),
        )
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(
        :elektron,
      ).and_return(elektron)
    end

    it_behaves_like "GET action with editor context" do
      subject do
        @default_params = default_params
        @extra_params = {}
        @path = "availability_zones"
        @result = {
          availability_zones: [
            { "label" => "qa-de-1a", "value" => "qa-de-1a", "enabled" => true },
            {
              "label" => "qa-de-1b",
              "value" => "qa-de-1b",
              "enabled" => false,
            },
          ],
        }
      end
    end
  end
end
