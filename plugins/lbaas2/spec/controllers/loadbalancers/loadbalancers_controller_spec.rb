# frozen_string_literal: true

require 'spec_helper'
require_relative '../factories/factories.rb'

describe Lbaas2::LoadbalancersController, type: :controller do
  routes { Lbaas2::Engine.routes }

  default_params = { domain_id: AuthenticationStub.domain_id,
                     project_id: AuthenticationStub.project_id }

  before(:all) do
    FriendlyIdEntry.find_or_create_entry(
      'Domain', nil, default_params[:domain_id], 'default'
    )
    FriendlyIdEntry.find_or_create_entry(
      'Project', default_params[:domain_id], default_params[:project_id],
      default_params[:project_id]
    )
  end

  describe "GET 'index'" do
    before :each do
      lbs = double('elektron', service: double("octavia", get: double("get", map_to: []) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(lbs)
      allow_any_instance_of(Lbaas2::LoadbalancersController).to receive(:extend_lb_data).and_return(double('lbaas').as_null_object)
    end

    context 'network_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
          token
        end
      end
      it 'returns http success' do
        get :index, params: default_params
        expect(response).to be_successful
      end
    end
    context 'network_viewer' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
          token
        end
      end
      it 'returns http success' do
        get :index, params: default_params
        expect(response).to be_successful
      end
    end
    context 'empty network roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token
        end
      end
      it 'returns 401 error' do
        get :index, params: default_params
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end

  describe "GET 'show'" do
    before :each do
      lbs = double('elektron', service: double("octavia", get: double("get", map_to: double("lb", to_json:{})) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(lbs)
      allow_any_instance_of(Lbaas2::LoadbalancersController).to receive(:extend_lb_data).and_return(double('lbaas').as_null_object)
    end

    context 'network_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
          token
        end
      end
      it 'returns http success' do
        get :show, params: default_params.merge(id: 'lb_id')
        expect(response).to be_successful
      end
    end
    context 'network_viewer' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
          token
        end
      end
      it 'returns http success' do
        get :show, params: default_params.merge(id: 'lb_id')
        expect(response).to be_successful
      end
    end
    context 'empty network roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token
        end
      end
      it 'returns 401 error' do
        get :show, params: default_params.merge(id: 'lb_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end

  describe "POST 'create'" do
    before :each do
      lbs = double('elektron', service: double("octavia", post: double("post", body: {}) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(lbs)
      allow_any_instance_of(Lbaas2::LoadbalancersController).to receive(:extend_lb_data).and_return(double('lbaas').as_null_object)
    end

    context 'network_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
          token
        end
      end

      it 'return http success' do
        lb = ::Lbaas2::FakeFactory.new.loadbalancer
        post :create, params: default_params.merge({loadbalancer: lb})
        expect(response).to be_successful
      end
    end

    context 'network_viewer' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
          token
        end
      end

      it 'return 401 error' do
        lb = ::Lbaas2::FakeFactory.new.loadbalancer
        post :create, params: default_params.merge({loadbalancer: lb})
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end

    context 'empty network roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token
        end
      end

      it 'return 401 error' do
        lb = ::Lbaas2::FakeFactory.new.loadbalancer
        post :create, params: default_params.merge({loadbalancer: lb})
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end

  end

  describe "DELETE 'destroy'" do
    before :each do
      lbs = double('elektron', service: double("octavia", delete: double("delete") ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(lbs)
    end

    context 'network_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
          token
        end
      end

      it 'return http success' do
        delete :destroy, params: default_params.merge(id: 'lb_id')
        expect(response).to be_successful
      end
    end

    context 'network_viewer' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
          token
        end
      end

      it 'return 401 error' do
        delete :destroy, params: default_params.merge(id: 'lb_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end

    context 'no network roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token
        end
      end

      it 'return 401 error' do
        delete :destroy, params: default_params.merge(id: 'lb_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end

  end

  describe "GET 'status_tree'" do
    before :each do
      lbs = double('elektron', service: double("octavia", get: double("get", map_to: double("status_tree", to_json:{})) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(lbs)
      allow_any_instance_of(Lbaas2::LoadbalancersController).to receive(:extend_lb_data).and_return(double('lbaas').as_null_object)
    end

    context 'network_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
          token
        end
      end
      it 'returns http success' do
        get :status_tree, params: default_params.merge(id: 'lb_id')
        expect(response).to be_successful
      end
    end
    context 'network_viewer' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
          token
        end
      end
      it 'returns http success' do
        get :status_tree, params: default_params.merge(id: 'lb_id')
        expect(response).to be_successful
      end
    end
    context 'empty network roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token
        end
      end
      it 'returns 401 error' do
        get :status_tree, params: default_params.merge(id: 'lb_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end

  describe "GET 'private_networks'" do
    before :each do
      allow_any_instance_of(ServiceLayer::NetworkingService).to receive(:project_networks).and_return([])
    end

    context 'network_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
          token
        end
      end
      it 'returns http success' do
        get :private_networks, params: default_params.merge(id: 'lb_id')
        expect(response).to be_successful
      end
    end
    context 'network_viewer' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
          token
        end
      end
      it 'returns 401 error' do
        get :private_networks, params: default_params.merge(id: 'lb_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
    context 'empty network roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token
        end
      end
      it 'returns 401 error' do
        get :private_networks, params: default_params.merge(id: 'lb_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end

  describe "GET 'subnets'" do
    before :each do
      allow_any_instance_of(ServiceLayer::NetworkingService).to receive(:find_network!).and_return(double("private_network", subnet_objects: nil))
    end

    context 'network_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
          token
        end
      end
      it 'returns http success' do
        get :subnets, params: default_params.merge(id: 'lb_id')
        expect(response).to be_successful
      end
    end
    context 'network_viewer' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
          token
        end
      end
      it 'returns 401 error' do
        get :subnets, params: default_params.merge(id: 'lb_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
    context 'empty network roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
          token
        end
      end
      it 'returns 401 error' do
        get :subnets, params: default_params.merge(id: 'lb_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end

end