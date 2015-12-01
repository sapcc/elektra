require 'spec_helper'

describe Inquiry::InquiriesController, type: :controller do
  routes { Inquiry::Engine.routes }

  include AuthenticationStub

  default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}

  before(:all) do
    FriendlyIdEntry.find_or_create_entry('Domain', nil, default_params[:domain_id], 'default')
    FriendlyIdEntry.find_or_create_entry('Project', default_params[:domain_id], default_params[:project_id], default_params[:project_id])
  end

  before :each do
    stub_authentication
    stub_admin_services
    @payload = { :key1 => "value1", :key2 => "value2" }.to_json
    @processors = [controller.current_user]
  end


  describe "create inquiry" do
    it 'creates a new Inquiry with initial status open' do
      expect {
        inq = controller.services.inquiry.inquiry_create("test", "test description", controller.current_user, @payload, @processors)
        expect(inq.aasm_state).to eq("open")
      }.to change { Inquiry::Inquiry.count }.by(1)

      expect(controller.services.inquiry.inquiries({:state => 'open'}).count).to eq 1

    end
  end

end
