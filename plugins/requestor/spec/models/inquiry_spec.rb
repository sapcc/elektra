require 'spec_helper'

describe 'Inquiry' do

  before(:all) do
    @payload = { :key1 => "value1", :key2 => "value2" }.to_json
  end

  describe 'Inquiry' do
    context 'Create' do

      it 'creates a new Inquiry with initial status open' do
        inq = Requestor::Inquiry.new()
        inq.payload = @payload
        expect(inq.aasm_state).to eq("open")
        expect {
          inq.save
        }.to change { Requestor::Inquiry.count }.by(1)

      end

      it 'changes state from open to approved and creates a step record for this' do
        inq = Requestor::Inquiry.new()
        inq.payload = @payload
        expect(inq.aasm_state).to eq("open")
        expect {
          inq.approve!({user_id: 4711, description: "For testing reasons"})
          expect(inq.aasm_state).to eq("approved")
        }.to change{inq.process_steps.count}.by(1)

        check = Requestor::Inquiry.find(inq.id)
        expect(check.process_steps.count).to eq(1)
        expect(check.process_steps.first.processor_id).to eq("4711")
        expect(check.process_steps.first.from_state).to eq("open")
        expect(check.process_steps.first.to_state).to eq("approved")
      end

      it 'changes state from open to rejected and creates a step record for this' do
        inq = Requestor::Inquiry.new()
        inq.payload = @payload
        expect(inq.aasm_state).to eq("open")
        expect {
          inq.reject!({user_id: 4711, description: "For testing reasons"})
          expect(inq.aasm_state).to eq("rejected")
        }.to change{inq.process_steps.count}.by(1)

        check = Requestor::Inquiry.find(inq.id)
        expect(check.process_steps.count).to eq(1)
        expect(check.process_steps.first.processor_id).to eq("4711")
        expect(check.process_steps.first.from_state).to eq("open")
        expect(check.process_steps.first.to_state).to eq("rejected")
      end

    end
  end
end
