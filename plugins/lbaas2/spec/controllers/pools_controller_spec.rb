
require 'spec_helper'
require_relative './factories/factories.rb'

describe Lbaas2::Loadbalancers::PoolsController, type: :controller do
  routes { Lbaas2::Engine.routes }

  default_params = {  domain_id: AuthenticationStub.domain_id,
                      project_id: AuthenticationStub.project_id,
                      loadbalancer_id: "lb_123456789" }

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
      pools = double('elektron', service: double("octavia", get: double("get", map_to: []) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(pools)
      allow_any_instance_of(Lbaas2::Loadbalancers::PoolsController).to receive(:extend_pool_data).and_return(double('cached_pools').as_null_object)
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
      pool = double('elektron', service: double("octavia", get: double("get", map_to: double("pool", to_json:{})) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(pool)
      allow_any_instance_of(Lbaas2::Loadbalancers::PoolsController).to receive(:extend_pool_data).and_return(double('cached_pools').as_null_object)
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
        get :show, params: default_params.merge(id: 'pool_id')
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
        get :show, params: default_params.merge(id: 'pool_id')
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
        get :show, params: default_params.merge(id: 'pool_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end

  describe "POST 'create'" do
    before :each do
      pool = double('elektron', service: double("octavia", post: double("post", body: {}) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(pool)
      allow_any_instance_of(Lbaas2::Loadbalancers::PoolsController).to receive(:extend_pool_data).and_return(double('cached_pools').as_null_object)
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
        pool = ::Lbaas2::FakeFactory.new.pool
        post :create, params: default_params.merge({pool: pool})
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
        pool = ::Lbaas2::FakeFactory.new.pool
        post :create, params: default_params.merge({pool: pool})
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
        pool = ::Lbaas2::FakeFactory.new.pool
        post :create, params: default_params.merge({pool: pool})
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end

  describe "DELETE 'destroy'" do
    before :each do
      pool = double('elektron', service: double("octavia", delete: double("delete") ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(pool)
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
        delete :destroy, params: default_params.merge(id: 'pool_id')
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
        delete :destroy, params: default_params.merge(id: 'pool_id')
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
        delete :destroy, params: default_params.merge(id: 'pool_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end

  describe "GET 'itemsForSelect'" do
    before :each do
      pools = double('elektron', service: double("octavia", get: double("get", map_to: []) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(pools)
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
        get :itemsForSelect, params: default_params
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
        get :itemsForSelect, params: default_params
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
        get :itemsForSelect, params: default_params
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end
end