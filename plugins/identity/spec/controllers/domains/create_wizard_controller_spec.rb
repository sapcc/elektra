# frozen_string_literal: true

require 'spec_helper'

# mockdata for host_aggregates api call
test_host_aggregates_empty_data=[]
test_host_aggregates_without_shard_data=[
  {
    "availability_zone": "qa-de-1a",
    "name": "qa-de-1a",
  },
  {
    "availability_zone": "qa-de-1b",
    "name": "qa-de-1b",
  }
]
test_host_aggregates_valid_data=[
  {
    "availability_zone": "qa-de-1a",
    "name": "qa-de-1a",
  },
  {
    "availability_zone": "qa-de-1b",
    "name": "qa-de-1b",
  },
  {
    "availability_zone": "qa-de-1a",
    "name": "vc-a-1",
  },
  {
    "availability_zone": "qa-de-1b",
    "name": "vc-b-0",
  },
  {
    "availability_zone": "qa-de-1a",
    "name": "vc-a-0",
  },
  {
    "availability_zone": "qa-de-1b",
    "name": "vc-b-1",
  },
  {
    "availability_zone": "qa-de-1a",
    "name": "vc-a-2",
  },
  {
    "availability_zone": "qa-de-1c",
    "name": "vc-c-0",
  },
]

describe Identity::Domains::CreateWizardController, type: :controller do
  routes { Identity::Engine.routes }

  default_params = { domain_id: AuthenticationStub.domain_id }

  before(:all) do
    FriendlyIdEntry.find_or_create_entry(
      'Domain', nil, default_params[:domain_id], 'default'
    )
  end

  before(:each) do
    stub_authentication
  end

  describe 'GET index' do
    it 'returns http success' do
      get :new, params: default_params
      expect(response).to be_successful
    end
  end

  describe 'calculate_highest_shards' do
    before :each do
      # prepare cloud_admin.compute for mocking data
      @compute=double("compute").as_null_object
      @cloud_admin=double("cloud_admin").as_null_object
      allow(@cloud_admin).to receive(:compute).and_return(@compute)
      allow_any_instance_of(::ApplicationController).to receive(:cloud_admin).and_return(@cloud_admin) # 
    end
    describe 'valid api data' do
      before :each do
        # define host_aggregates for cloud_admin.compute
        allow(@compute).to receive(:host_aggregates).and_return(test_host_aggregates_valid_data.map{|data| Compute::HostAggregate.new(nil, data)}) #devine host_aggregates for cloudadmin
      end
      it 'should return the highest shards' do
        #p controller.cloud_admin.host_aggregates
        expect(controller.calculate_highest_shards).to eql(["vc-a-2", "vc-b-1", "vc-c-0"])
      end
    end
    describe 'empty api data' do
      before :each do
        allow(@compute).to receive(:host_aggregates).and_return(test_host_aggregates_empty_data.map{|data| Compute::HostAggregate.new(nil, data)}) 
      end
      it 'should return empty shard array' do
        expect(controller.calculate_highest_shards).to eql([])
      end
    end
    describe 'empty shard data' do
      before :each do
        allow(@compute).to receive(:host_aggregates).and_return(test_host_aggregates_without_shard_data.map{|data| Compute::HostAggregate.new(nil, data)})
      end
      it 'should return empty shard array' do
        expect(controller.calculate_highest_shards).to eql([])
      end
    end
  end
end
