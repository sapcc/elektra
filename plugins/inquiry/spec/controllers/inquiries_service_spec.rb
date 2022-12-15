require "spec_helper"

describe Inquiry::InquiriesController, type: :controller do
  routes { Inquiry::Engine.routes }

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

    get :index, params: { domain_id: AuthenticationStub.domain_id }
    @payload = { key1: "value1", key2: "value2" }.to_json
    @processors = [controller.current_user]
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  describe "create and process inquiry" do
    it "creates open Inquiry , approves it and processes further states correctly" do
      expect {
        inq =
          controller.services.inquiry.create_inquiry(
            "test",
            "test description",
            controller.current_user,
            @payload,
            @processors,
          )
        expect(inq.aasm_state).to eq("open")
      }.to change { Inquiry::Inquiry.count }.by(1)

      expect(
        controller.services.inquiry.get_inquiries({ state: "open" }).count,
      ).to eq 1

      inq =
        controller.services.inquiry.create_inquiry(
          "test",
          "test description",
          controller.current_user,
          @payload,
          @processors,
        )
      expect(
        controller.services.inquiry.get_inquiries({ state: "open" }).count,
      ).to eq 2

      controller.services.inquiry.set_inquiry_state(
        inq.id,
        "approved",
        "Set state to approved",
        controller.current_user,
      )
      expect(
        controller.services.inquiry.get_inquiries({ state: "open" }).count,
      ).to eq 1
      expect(
        controller.services.inquiry.get_inquiries({ state: "approved" }).count,
      ).to eq 1

      expect {
        controller.services.inquiry.set_inquiry_state(
          inq.id,
          "rejected",
          "Set state to rejected",
          controller.current_user,
        )
      }.to raise_error Exception

      expect {
        controller.services.inquiry.set_inquiry_state(
          inq.id,
          "open",
          "Set state to open",
          controller.current_user,
        )
      }.to raise_error Exception

      controller.services.inquiry.set_inquiry_state(
        inq.id,
        "closed",
        "Set state to closed",
        controller.current_user,
      )
      expect(
        controller.services.inquiry.get_inquiries({ state: "open" }).count,
      ).to eq 1
      expect(
        controller.services.inquiry.get_inquiries({ state: "approved" }).count,
      ).to eq 0
      expect(
        controller.services.inquiry.get_inquiries({ state: "closed" }).count,
      ).to eq 1
    end
  end

  describe "create and process inquiry" do
    it "creates open Inquiry , approves it and processes further states correctly" do
      expect {
        inq =
          controller.services.inquiry.create_inquiry(
            "test",
            "test description",
            controller.current_user,
            @payload,
            @processors,
          )
        expect(inq.aasm_state).to eq("open")
      }.to change { Inquiry::Inquiry.count }.by(1)

      expect(
        controller.services.inquiry.get_inquiries({ state: "open" }).count,
      ).to eq 1

      inq =
        controller.services.inquiry.create_inquiry(
          "test",
          "test description",
          controller.current_user,
          @payload,
          @processors,
        )
      expect(
        controller.services.inquiry.get_inquiries({ state: "open" }).count,
      ).to eq 2

      controller.services.inquiry.set_inquiry_state(
        inq.id,
        "rejected",
        "Set state to rejected",
        controller.current_user,
      )
      expect(
        controller.services.inquiry.get_inquiries({ state: "open" }).count,
      ).to eq 1
      expect(
        controller.services.inquiry.get_inquiries({ state: "rejected" }).count,
      ).to eq 1

      expect {
        controller.services.inquiry.set_inquiry_state(
          inq.id,
          "approved",
          "Set state to approved",
          controller.current_user,
        )
      }.to raise_error Exception

      controller.services.inquiry.set_inquiry_state(
        inq.id,
        "open",
        "Set state to open",
        controller.current_user,
      )
      expect(
        controller.services.inquiry.get_inquiries({ state: "open" }).count,
      ).to eq 2

      controller.services.inquiry.set_inquiry_state(
        inq.id,
        "rejected",
        "Set state to rejected",
        controller.current_user,
      )
      expect(
        controller.services.inquiry.get_inquiries({ state: "open" }).count,
      ).to eq 1
      expect(
        controller.services.inquiry.get_inquiries({ state: "rejected" }).count,
      ).to eq 1

      controller.services.inquiry.set_inquiry_state(
        inq.id,
        "closed",
        "Set state to closed",
        controller.current_user,
      )
      expect(
        controller.services.inquiry.get_inquiries({ state: "open" }).count,
      ).to eq 1
      expect(
        controller.services.inquiry.get_inquiries({ state: "rejected" }).count,
      ).to eq 0
      expect(
        controller.services.inquiry.get_inquiries({ state: "closed" }).count,
      ).to eq 1
    end
  end
end
