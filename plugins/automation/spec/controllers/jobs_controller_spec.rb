require 'spec_helper'

describe Automation::JobsController, type: :controller do
  routes { Automation::Engine.routes }

  

  default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}

  before(:all) do
    FriendlyIdEntry.find_or_create_entry('Domain',nil,default_params[:domain_id],'default')
    FriendlyIdEntry.find_or_create_entry('Project',default_params[:domain_id],default_params[:project_id],default_params[:project_id])
  end

  before :each do
    stub_authentication
    stub_admin_services

    identity_driver = double('identity_service_driver').as_null_object
    compute_driver = double('compute_service_driver').as_null_object

    allow_any_instance_of(ServiceLayer::IdentityService).to receive(:driver).and_return(identity_driver)
    allow_any_instance_of(ServiceLayer::ComputeService).to receive(:driver).and_return(compute_driver)
  end

  # describe "GET 'show'" do
  #
  #   before :each do
  #     @agent_id = 'kuack_kuack'
  #     @job_id = 'miau_bup'
  #     @payload =  "First line \n second line \n third line"
  #     @log = log_output
  #     @job = double('job', created_at: '2016-02-29T10:18:34.708279Z', updated_at: '2016-02-29T10:18:49.708279Z', payload: @payload)
  #     allow_any_instance_of(ServiceLayer::AutomationService).to receive(:job).with(@job_id).and_return(@job)
  #     allow_any_instance_of(ServiceLayer::AutomationService).to receive(:job_log).with(@job_id).and_return(@log)
  #   end
  #
  #   it "returns http success" do
  #     get :show, default_params.merge!({agent_id: @agent_id, id: @job_id})
  #     expect(response).to be_success
  #   end
  #
  #   it "should calculate the duration" do
  #     get :show, default_params.merge!({agent_id: @agent_id, id: @job_id})
  #     expect(assigns(:duration)).to eq('00:00:15')
  #   end
  #
  #   it "should calculate the payload and log lines" do
  #     get :show, default_params.merge!({agent_id: @agent_id, id: @job_id})
  #     expect(assigns(:payload_lines)).to eq(3)
  #     expect(assigns(:log_lines)).to eq(27)
  #   end
  #
  #   it "should evaluate if log and payload are truncated" do
  #     get :show, default_params.merge!({agent_id: @agent_id, id: @job_id})
  #     expect(assigns(:payload_truncated)).to eq(false)
  #     expect(assigns(:log_truncated)).to eq(true)
  #   end
  #
  #   it "should assign the log and payload" do
  #     get :show, default_params.merge!({agent_id: @agent_id, id: @job_id})
  #     expect(assigns(:payload_output)).to eq(@payload)
  #     expect(@log).to include(assigns(:log_output))
  #   end
  #
  # end

end

def log_output
  output = ""
  for i in 0..26
    output << "Line #{i}\n"
  end
  output
end