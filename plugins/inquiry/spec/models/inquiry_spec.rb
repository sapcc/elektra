require 'spec_helper'

describe 'Inquiry' do

  before(:all) do
    @payload = {:key1 => "value1", :key2 => "value2"}.to_json
    token = AuthenticationStub.test_token
    @user = MonsoonOpenstackAuth::Authentication::AuthUser.new('europe', token)
    @processors = Inquiry::Processor.from_users([@user])
  end

  describe 'Inquiry' do
    skip do
      context 'Create' do

        it 'creates a new Inquiry with initial status open' do
          inq = Inquiry::Inquiry.new()
          inq.payload = @payload
          inq.processors = @processors
          expect(inq.aasm_state).to eq("open")
          expect {
            inq.save
          }.to change { Inquiry::Inquiry.count }.by(1)

          puts inq
        end

        it 'changes state from open to approved and creates a step record for this' do
          inq = Inquiry::Inquiry.new(processors: @processors)
          inq.payload = @payload
          inq.save
          expect(inq.aasm_state).to eq("open")
          expect {
            inq.approve!({user: @user, description: "For testing reasons"})
            expect(inq.aasm_state).to eq("approved")
          }.to change { inq.process_steps.count }.by(1)

          check = Inquiry::Inquiry.find(inq.id)
          expect(check.process_steps.count).to eq(1)
          #expect(check.process_steps.first.processor.uid).to eq(@user.id)
          expect(check.process_steps.first.from_state).to eq("open")
          expect(check.process_steps.first.to_state).to eq("approved")
        end

        it 'changes state from open to rejected and creates a step record for this' do
          inq = Inquiry::Inquiry.new(processors: @processors)
          inq.payload = @payload
          inq.save
          expect(inq.aasm_state).to eq("open")
          expect {
            inq.reject!({user: @user, description: "For testing reasons"})
            expect(inq.aasm_state).to eq("rejected")
          }.to change { inq.process_steps.count }.by(1)

          check = Inquiry::Inquiry.find(inq.id)
          expect(check.process_steps.count).to eq(1)
          #expect(check.process_steps.first.processor.uid).to eq(@user.id)
          expect(check.process_steps.first.from_state).to eq("open")
          expect(check.process_steps.first.to_state).to eq("rejected")
        end

      end
    end
  end
end
