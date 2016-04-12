require 'spec_helper'

RSpec.describe InstallNodeService do

  describe 'process_request' do

    before(:each) do
      @instance_id = 'some_nice_instance_id'
      @os = 'linux'
      @url = 'some_nice_url'
      @script = 'some cool script'
      @automation_service = double('automation_service')
      @active_project = double('active_project', id: 'miau', domain_id: 'bup')
      @service = InstallNodeService.new()
    end

    it 'should raise an exception if instance_id is empty or nil' do
      # empty
      expect { @service.process_request('', '', '', nil, nil, '', '') }.to raise_error(InstallNodeParamError)
      # blank
      expect { @service.process_request(nil, '', '', nil, nil, '', '') }.to raise_error(InstallNodeParamError)
    end

    context 'compute instance' do

      before(:each) do
        @instance_type = 'compute'
      end

      it 'should raise an exception if instance not found' do
        Object.const_set 'NotFound', Class.new(StandardError)
        compute_service = double('compute_service')
        allow(compute_service).to receive(:find_server){ raise Core::ServiceLayer::Errors::ApiError.new(NotFound.new('test')) }
        expect { @service.process_request(@instance_id, @instance_type, '', compute_service, nil, '', '') }.to raise_error(InstallNodeParamError)
      end

      it "should not raise an error if agent already exists on the instance" do
        instance = double('instance', id: @instance_id, name: 'instance_name', image: double('image', name: 'cuak_cuak', metadata: {}), addresses: {'first_ip' => [{'addr' => 'this_is_the_ip'}]}, metadata: double('metadata', dns_name: ''))
        compute_service = double('compute_service', find_server: instance)
        allow(@automation_service).to receive(:node){ true }

        expect { @service.process_request(@instance_id, @instance_type, '', compute_service, @automation_service, @active_project, '') }.to raise_error(InstallNodeInstanceOSNotFound)
      end

      it "should raise an exception if instance_os and image metadata os_family are empty or nil" do
        instance = double('instance', id: @instance_id, image: double('image', name: 'cuak_cuak', metadata: {}))
        compute_service = double('compute_service', find_server: instance)
        allow(@automation_service).to receive(:node){ raise ::RestClient::ResourceNotFound.new() }

        expect { @service.process_request(@instance_id, @instance_type,  '', compute_service, @automation_service, '', '') }.to raise_error(InstallNodeInstanceOSNotFound, "Instance OS empty or not known")
        expect { @service.process_request(@instance_id, @instance_type, nil, compute_service, @automation_service, '', '') }.to raise_error(InstallNodeInstanceOSNotFound, "Instance OS empty or not known")
      end

      it "should get the image metadata os_family when input param instance_os is empty or nil" do
        instance = double('instance', id: @instance_id, image: double('image', name: 'cuak_cuak', metadata: {'os_family'=> @os}), addresses: {}, metadata: double('metadata', dns_name: ''))
        compute_service = double('compute_service', find_server: instance)
        allow(@automation_service).to receive(:node){ raise ::RestClient::ResourceNotFound.new() }
        allow(RestClient::Request).to receive(:new).and_return( double('response', execute: {url: @url}.to_json) )
        allow(@service).to receive(:create_script).with(@url,@os).and_return( @script )

        expect( @service.process_request(@instance_id, @instance_type, '', compute_service, @automation_service, @active_project, '') ).to match( {log_info: '',  messages: [], instance: instance, script: @script} )
      end

      it "should return the right log info" do
        instance = double('instance', id: @instance_id, image: double('image', name: 'cuak_cuak', metadata: {'os_family'=> @os}), addresses: {'first_ip' => [{'addr' => 'this_is_the_ip'}]}, metadata: double('metadata', dns_name: 'mo_hash'))
        compute_service = double('compute_service', find_server: instance)
        allow(@automation_service).to receive(:node){ raise ::RestClient::ResourceNotFound.new() }
        allow(RestClient::Request).to receive(:new).and_return(double('response', execute: {url: @url}.to_json))
        allow(@service).to receive(:create_script).with(@url, @os).and_return( @script )

        expect( @service.process_request(@instance_id, @instance_type, '', compute_service, @automation_service, @active_project, '') ).to match( {log_info: 'this_is_the_ip / mo_hash', messages: [], instance: instance, script: @script} )
      end

    end

    context 'external' do

    end

  end

end