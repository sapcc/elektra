require 'spec_helper'

RSpec.describe IndexAgentsService do

  describe 'initialization' do

    it "should raise an error if no automation_service is given" do
      expect { IndexAgentsService.new(nil)}.to raise_error(IndexAgentsServiceParamError, 'Automation service parameter empty.')
    end

    it "should initialize an object" do
      automation_service = double('automation_service')
      expect { IndexAgentsService.new(automation_service)}.not_to raise_error
      expect(IndexAgentsService.new(automation_service)).not_to be_nil
    end

  end

  describe 'list_agents' do

    it "should return all agents with the corresponding jobs" do
      agent1 = double('agent1', id: 'agent1')
      agent2 = double('agent2', id: 'agent2')
      agent1_jobs = double('jobs_agent1', data: [{request_id:'agent1_1'}, {request_id:'agent1_2'}, {request_id:'agent1_3'}, {request_id:'agent1_4'}, {request_id:'agent1_5'}])
      agent2_jobs = double('jobs_agent2', data: [{request_id:'agent2_1'}, {request_id:'agent2_2'}, {request_id:'agent2_3'}, {request_id:'agent2_4'}, {request_id:'agent2_5'}])
      automation_service = double('automation_service', agents: {elements: [agent1, agent2]})

      allow(automation_service).to receive(:jobs).with('agent1', 1, 5) { agent1_jobs }
      allow(automation_service).to receive(:jobs).with('agent2', 1, 5) { agent2_jobs }

      expect(IndexAgentsService.new(automation_service).list_agents(1,5)).to match( {:elements=>[agent1, agent2], :jobs=>{:agent1=>agent1_jobs, :agent2=>agent2_jobs}} )
    end

  end

end