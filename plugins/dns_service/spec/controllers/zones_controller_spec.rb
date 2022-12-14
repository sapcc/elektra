# frozen_string_literal: true

require "spec_helper"

describe DnsService::ZonesController, type: :controller do
  routes { DnsService::Engine.routes }
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
    dns_service_driver = double("dns_service_driver").as_null_object

    allow_any_instance_of(ServiceLayer::DnsServiceService).to receive(
      :elektron,
    ).and_return(dns_service_driver)
    allow_any_instance_of(ServiceLayer::DnsServiceService).to receive(
      :zone_transfer_requests,
    ).and_return([])
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, params: default_params
      expect(response).to be_successful
    end
  end
end
