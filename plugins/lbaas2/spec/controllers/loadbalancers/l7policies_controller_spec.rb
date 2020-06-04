# frozen_string_literal: true

require 'spec_helper'
require_relative '../factories/factories.rb'

describe Lbaas2::Loadbalancers::Listeners::L7policiesController, type: :controller do
  routes { Lbaas2::Engine.routes }

  default_params = {  domain_id: AuthenticationStub.domain_id,
                      project_id: AuthenticationStub.project_id,
                      loadbalancer_id: "lb_123456789",
                      listener_id: "listener_123456789" }

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
      l7policies = double('elektron', service: double("octavia", get: double("get", map_to: []) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(l7policies)
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
      l7policy = double('elektron', service: double("octavia", get: double("get", map_to: double("l7policy", to_json:{})) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(l7policy)
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
        get :show, params: default_params.merge(id: 'l7policy_id')
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
        get :show, params: default_params.merge(id: 'l7policy_id')
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
        get :show, params: default_params.merge(id: 'l7policy_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end

  describe "POST 'create'" do
    before :each do
      l7policy = double('elektron', service: double("octavia", post: double("post", body: {}) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(l7policy)
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
        l7policy = ::Lbaas2::FakeFactory.new.l7policy
        post :create, params: default_params.merge({l7policy: l7policy})
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
        l7policy = ::Lbaas2::FakeFactory.new.l7policy
        post :create, params: default_params.merge({l7policy: l7policy})
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
        l7policy = ::Lbaas2::FakeFactory.new.l7policy
        post :create, params: default_params.merge({l7policy: l7policy})
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end
end