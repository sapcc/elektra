require 'spec_helper'

describe 'Inquiry' do

  before(:all) do
    @payload = {:key1 => "value1", :key2 => "value2"}.to_json
    token = AuthenticationStub.test_token
    @user = ApplicationController::CurrentUserWrapper.new(MonsoonOpenstackAuth::Authentication::AuthUser.new(token),{},nil)
  end

  before(:each) do
    @processors = Inquiry::Processor.from_users([@user])
  end

  describe 'Inquiry' do
#    skip do
      context 'Create' do

        it 'creates a new Inquiry with initial status open' do
          inq = Inquiry::Inquiry.new(description: "Test", requester: @processors[0])
          inq.payload = @payload
          inq.processors = @processors
          expect(inq.aasm_state).to eq("new")
          expect {
            inq.save
          }.to change { Inquiry::Inquiry.count }.by(1)
          expect(inq.aasm_state).to eq("open")
        end

        it 'changes state from open to approved and creates a step record for this' do
          inq = Inquiry::Inquiry.new(description: "Test", requester: @processors[0])
          inq.payload = @payload
          inq.processors = @processors
          inq.save
          expect(inq.aasm_state).to eq("open")
          expect {
            inq.approve!({user: @user, description: "For testing reasons"})
            expect(inq.aasm_state).to eq("approved")
          }.to change { inq.process_steps.count }.by(1)

          check = Inquiry::Inquiry.find(inq.id)
          expect(check.process_steps.count).to eq(2)
          expect(check.process_steps.first.from_state).to eq("new")
          expect(check.process_steps.first.to_state).to eq("open")
          expect(check.process_steps.second.from_state).to eq("open")
          expect(check.process_steps.second.to_state).to eq("approved")
        end

        it 'changes state from open to rejected and creates a step record for this' do
          inq = Inquiry::Inquiry.new(description: "Test", requester: @processors[0])
          inq.payload = @payload
          inq.processors = @processors
          inq.save
          inq.reload
          expect(inq.aasm_state).to eq("open")
          expect {
            inq.reject!({user: @user, description: "For testing reasons"})
            expect(inq.aasm_state).to eq("rejected")
          }.to change { inq.process_steps.count }.by(1)

          check = Inquiry::Inquiry.find(inq.id)
          expect(check.process_steps.count).to eq(2)
          expect(check.process_steps.first.from_state).to eq("new")
          expect(check.process_steps.first.to_state).to eq("open")
          expect(check.process_steps.second.from_state).to eq("open")
          expect(check.process_steps.second.to_state).to eq("rejected")
        end

      end
    end
#  end
end
