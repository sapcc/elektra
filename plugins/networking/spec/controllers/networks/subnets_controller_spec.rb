# frozen_string_literal: true

require "spec_helper"

describe Networking::Networks::SubnetsController, type: :controller do
  routes { Networking::Engine.routes }

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
    stub_authentication
    allow_any_instance_of(ServiceLayer::NetworkingService).to receive(
      :elektron,
    ).and_return(double("elektron", service: double("network").as_null_object))

    allow_any_instance_of(ServiceLayer::ResourceManagementService).to receive(
      :quota_data,
    ).and_return([])
  end

  describe "GET 'index'" do
    before :each do
      allow_any_instance_of(ServiceLayer::NetworkingService).to receive(
        :subnets,
      ).with(network_id: "123").and_return(["test1"])
    end

    it "returns success" do
      get :index, params: default_params.merge(network_id: "123")
      expect(response).to be_successful
    end

    it "returns an json" do
      get :index, params: default_params.merge(network_id: "123")
      expect(response.body).to eq(["test1"].to_json)
    end

    it "calls api to list all subnets" do
      expect_any_instance_of(ServiceLayer::NetworkingService).to receive(
        :subnets,
      ).with(network_id: "123")
      get :index, params: default_params.merge(network_id: "123")
    end
  end

  describe "POST 'create'" do
    subnet_params = {
      name: "test",
      ip_version: 4,
      cidr: "10.180.0.0/8",
      network_id: "123",
      enable_dhcp: true,
      segment_id: nil,
      project_id: "4fd44f30292945e481c7b8a0c8908869",
      tenant_id: "4fd44f30292945e481c7b8a0c8908869",
      dns_nameservers: [],
      allocation_pools: [{ start: "192.168.199.2", end: "192.168.199.254" }],
      host_routes: [],
      gateway_ip: "192.168.199.1",
      id: "3b80198d-4f7b-4f77-9ef5-774d54e17126",
      created_at: "2016-10-10T14:35:47Z",
      description: "",
      ipv6_address_mode: nil,
      ipv6_ra_mode: nil,
      revision_number: 1,
      service_types: [],
      subnetpool_id: nil,
      updated_at: "2016-10-10T14:35:47Z",
    }

    create_params =
      subnet_params.select do |k, _v|
        %i[name ip_version cidr network_id].include?(k)
      end

    context "api returns success" do
      before :each do
        allow_any_instance_of(ServiceLayer::NetworkingService).to receive(
          :create_subnet,
        ).with(create_params.with_indifferent_access).and_return(
          subnet_params.with_indifferent_access,
        )
      end

      it "returns 201" do
        post :create,
             params:
               default_params.merge(
                 network_id: "123",
                 subnet: {
                   name: subnet_params[:name],
                   cidr: subnet_params[:cidr],
                 },
               )
        expect(response.status).to eq(201)
      end

      it "returns an json" do
        post :create,
             params:
               default_params.merge(
                 network_id: "123",
                 subnet: {
                   name: subnet_params[:name],
                   cidr: subnet_params[:cidr],
                 },
               )

        expect { JSON.parse(response.body) }.not_to raise_error
      end

      it "calls api for create a new subnet" do
        expect_any_instance_of(ServiceLayer::NetworkingService).to receive(
          :create_subnet,
        ).with(create_params.with_indifferent_access)

        post :create,
             params:
               default_params.merge(
                 network_id: "123",
                 subnet: {
                   name: subnet_params[:name],
                   cidr: subnet_params[:cidr],
                 },
               )
        expect(JSON.parse(response.body)["id"]).to eq(subnet_params[:id])
      end
    end

    context "validation errors" do
      it "returns json with cidr range errors" do
        post :create,
             params:
               default_params.merge(
                 network_id: "123",
                 subnet: {
                   name: "test",
                   cidr: "192.168.199.0/24",
                 },
               )
        expect(response.body).to eq(
          {
            errors: {
              cidr: ["must be a valid cidr adress like 10.180.1.0/16"],
            },
          }.to_json,
        )
      end

      it "returns json with cidr errors" do
        post :create,
             params:
               default_params.merge(network_id: "123", subnet: { name: "test" })
        expect(response.body).to eq(
          {
            errors: {
              cidr: [
                "can't be blank",
                "must be a valid cidr adress like 10.180.1.0/16",
              ],
            },
          }.to_json,
        )
      end

      it "returns json with name errors" do
        post :create,
             params:
               default_params.merge(
                 network_id: "123",
                 subnet: {
                   cidr: "10.180.0.0/8",
                 },
               )
        expect(response.body).to eq(
          { errors: { name: ["can't be blank"] } }.to_json,
        )
      end
    end

    context "api returns an error" do
      before :each do
        response = OpenStruct.new(code: 404)
        allow_any_instance_of(ServiceLayer::NetworkingService).to receive(
          :delete_subnet,
        ).and_raise(Elektron::Errors::ApiResponse, response)
      end

      it "returns 400" do
        post :create,
             params:
               default_params.merge(network_id: "123", subnet: { name: "test" })
        expect(response.status).to eq(400)
      end
    end
  end

  describe "DELETE 'destroy'" do
    context "api returns a success" do
      it "returns 204" do
        delete :destroy,
               params: default_params.merge(network_id: "123", id: "456")
        expect(response.status).to eq(204)
      end

      it "calls api for destroy a subnet" do
        expect_any_instance_of(ServiceLayer::NetworkingService).to receive(
          :delete_subnet,
        ).with("456")
        delete :destroy,
               params: default_params.merge(network_id: "123", id: "456")
      end
    end

    context "api returns an error" do
      before :each do
        error_response =
          OpenStruct.new(code: 404, body: { "message" => "Error" })
        allow_any_instance_of(ServiceLayer::NetworkingService).to receive(
          :delete_subnet,
        ).and_raise(Elektron::Errors::ApiResponse.new(error_response))
      end

      it "renders an json with error" do
        delete :destroy,
               params: default_params.merge(network_id: "123", id: "456")
        expect do
          body = JSON.parse(response.body)
          expect(body["errors"]).not_to be_nil
        end.not_to raise_error
      end

      it "returns 400" do
        delete :destroy,
               params: default_params.merge(network_id: "123", id: "456")
        expect(response.status).to eq(400)
      end
    end
  end
end
