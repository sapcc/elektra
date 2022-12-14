require "spec_helper"

describe "Inquiry" do
  before(:all) { @payload = { key1: "value1", key2: "value2" }.to_json }

  before(:each) do
    token = AuthenticationStub.test_token

    service_user =
      double(
        "service_user",
        identity:
          double(
            "identity",
            id: "123",
            name: "service_user_name",
            email: "service_user_email",
            full_name: "service_user_fullname",
          ).as_null_object,
      )

    @user =
      ApplicationController::CurrentUserWrapper.new(
        MonsoonOpenstackAuth::Authentication::AuthUser.new(token),
        {},
        service_user,
      )
    allow(@user).to receive(:email).and_return("test@test.com")
    allow(@user).to receive(:full_name).and_return("test")
    @processors = Inquiry::Processor.from_users([@user])
  end

  describe "Inquiry" do
    context "Create" do
      it "creates a new Inquiry with initial status open" do
        inq =
          Inquiry::Inquiry.new(
            description: "Test",
            requester: @processors[0],
            domain_id: "default",
            approver_domain_id: "default",
          )
        inq.payload = @payload
        inq.processors = @processors
        expect(inq.aasm_state).to eq("new")
        expect do inq.save end.to change { Inquiry::Inquiry.count }.by(1)
        expect(inq.aasm_state).to eq("open")
      end

      it "changes state from open to approved and creates a step record for this" do
        inq =
          Inquiry::Inquiry.new(
            description: "Test",
            requester: @processors[0],
            domain_id: "default",
            approver_domain_id: "default",
          )
        inq.payload = @payload
        inq.processors = @processors
        inq.save
        expect(inq.aasm_state).to eq("open")
        expect do
          inq.approve!(user: @user, description: "For testing reasons")
          expect(inq.aasm_state).to eq("approved")
        end.to change { inq.process_steps.count }.by(1)

        check = Inquiry::Inquiry.find(inq.id)
        expect(check.process_steps.count).to eq(2)
        expect(check.process_steps.first.from_state).to eq("new")
        expect(check.process_steps.first.to_state).to eq("open")
        expect(check.process_steps.second.from_state).to eq("open")
        expect(check.process_steps.second.to_state).to eq("approved")
      end

      it "changes state from open to rejected and creates a step record for this" do
        inq =
          Inquiry::Inquiry.new(
            description: "Test",
            requester: @processors[0],
            domain_id: "default",
            approver_domain_id: "default",
          )
        inq.payload = @payload
        inq.processors = @processors
        inq.save
        inq.reload
        expect(inq.aasm_state).to eq("open")
        expect do
          inq.reject!(user: @user, description: "For testing reasons")
          expect(inq.aasm_state).to eq("rejected")
        end.to change { inq.process_steps.count }.by(1)

        check = Inquiry::Inquiry.find(inq.id)
        expect(check.process_steps.count).to eq(2)
        expect(check.process_steps.first.from_state).to eq("new")
        expect(check.process_steps.first.to_state).to eq("open")
        expect(check.process_steps.second.from_state).to eq("open")
        expect(check.process_steps.second.to_state).to eq("rejected")
      end
    end
  end
end
