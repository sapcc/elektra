require 'spec_helper'

RSpec.describe InstallAgentService do

  describe 'process_request' do

    it 'should raise an exception if instance_id is empty or nil' do
      # empty
      expect { InstallAgentService.new().process_request('', '', nil, nil, '', '') }.to raise_error(InstallAgentParamError, 'Instance id empty')
      # blank
      expect { InstallAgentService.new().process_request(nil, '', nil, nil, '', '') }.to raise_error(InstallAgentParamError, 'Instance id empty')
    end

    it 'should raise an exception if instance not found' do
      instance_id = 'some_nice_id'
      Object.const_set 'NotFound', Class.new(StandardError)
      @compute_service = double('compute_service')
      allow(@compute_service).to receive(:find_server){ raise Core::ServiceLayer::Errors::ApiError.new(NotFound.new('test')) }
      expect { InstallAgentService.new().process_request(instance_id, '', @compute_service, nil, '', '') }.to raise_error(InstallAgentParamError, "Instance with id #{instance_id} not found")
    end

    it "should raise an error if agent already exists on the instance" do
      instance_id = 'some_nice_id'
      @instance = double('instance', id: instance_id, image: double('image', name: 'cuak_cuak'))
      @compute_service = double('compute_service', find_server: @instance)
      @automation_service = double('automation_service', agent: true)

      expect { InstallAgentService.new().process_request(instance_id, '', @compute_service, @automation_service, '', '') }.to raise_error(InstallAgentAlreadyExists, "Agent already exists on instance id #{@instance.id} (#{@instance.image.name})")
    end

    it "should raise an exception if instance_os and image metadata os_family are empty or nil" do
      instance_id = 'some_nice_id'
      @instance = double('instance', id: instance_id, image: double('image', name: 'cuak_cuak', metadata: {}))
      @compute_service = double('compute_service', find_server: @instance)
      @automation_service = double('automation_service')
      allow(@automation_service).to receive(:agent){ raise ::RestClient::ResourceNotFound.new() }

      expect { InstallAgentService.new().process_request(instance_id, '', @compute_service, @automation_service, '', '') }.to raise_error(InstallAgentInstanceOSNotFound, "Instance OS empty or not known")
      expect { InstallAgentService.new().process_request(instance_id, nil, @compute_service, @automation_service, '', '') }.to raise_error(InstallAgentInstanceOSNotFound, "Instance OS empty or not known")
    end

    it "should get the image metadata os_family when input param instance_os is empty or nil" do
      instance_id = 'some_nice_id'
      @instance = double('instance', id: instance_id, image: double('image', name: 'cuak_cuak', metadata: {'os_family'=> 'linux'}), addresses: {})
      @compute_service = double('compute_service', find_server: @instance)
      @automation_service = double('automation_service')
      @active_project = double('active_project', id: 'miau', domain_id: 'bup')
      allow(@automation_service).to receive(:agent){ raise ::RestClient::ResourceNotFound.new() }
      allow(RestClient::Request).to receive(:new).and_return(double('response', execute: {url: 'some_nice_url'}.to_json))

      expect( InstallAgentService.new().process_request(instance_id, '', @compute_service, @automation_service, @active_project, '') ).to match( {url: 'some_nice_url', ip: "", instance_os: 'linux', instance: @instance} )
    end


    it "should set the first ip from instance addresses" do
      instance_id = 'some_nice_id'
      @instance = double('instance', id: instance_id, image: double('image', name: 'cuak_cuak', metadata: {'os_family'=> 'linux'}), addresses: {'first_ip' => [{'addr' => 'this_is_the_ip'}]})
      @compute_service = double('compute_service', find_server: @instance)
      @automation_service = double('automation_service')
      @active_project = double('active_project', id: 'miau', domain_id: 'bup')
      allow(@automation_service).to receive(:agent){ raise ::RestClient::ResourceNotFound.new() }
      allow(RestClient::Request).to receive(:new).and_return(double('response', execute: {url: 'some_nice_url'}.to_json))

      expect( InstallAgentService.new().process_request(instance_id, '', @compute_service, @automation_service, @active_project, '') ).to match( {url: 'some_nice_url', ip: "this_is_the_ip", instance_os: 'linux', instance: @instance} )
    end

  end

end