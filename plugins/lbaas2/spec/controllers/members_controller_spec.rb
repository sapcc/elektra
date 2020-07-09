# frozen_string_literal: true

require 'spec_helper'
require_relative './factories/factories.rb'
require_relative 'shared'

describe Lbaas2::Loadbalancers::Pools::MembersController, type: :controller do
  routes { Lbaas2::Engine.routes }

  default_params = {  domain_id: AuthenticationStub.domain_id,
                      project_id: AuthenticationStub.project_id,
                      loadbalancer_id: "lb_123456789",
                      pool_id: "pool_123456789" }

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
      members = double('elektron', service: double("octavia", get: double("get", map_to: []) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(members)
    end

    it_behaves_like 'index action' do
      subject do
        @default_params = default_params
      end
    end

  end

  describe "GET 'show'" do
    before :each do
      member = double('elektron', service: double("octavia", get: double("get", map_to: double("member", to_json:{})) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(member)
    end

    it_behaves_like 'show action' do
      subject do
        @default_params = default_params
      end
    end

  end

  describe "PUT 'update'" do
    before :each do
      member = double('elektron', service: double("octavia", get: double("get", map_to: double("member", to_json:{}, identifier:"", attributes:{}, update_attributes: {}, update:{})), put: double("put", body: {}) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(member)
      allow_any_instance_of(Lbaas2::Loadbalancers::Pools::MembersController).to receive(:parseMemberParams).and_return(::Lbaas2::FakeFactory.new.member_params)
    end

    context 'network_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
          token
        end
      end
      it 'return http success' do
        member = ::Lbaas2::FakeFactory.new.update_member
        put :update, params: default_params.merge({id: member[:id], member: member})
        expect(response).to be_successful
      end
    end
    context 'loadbalancer_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_admin' }
          token
        end
      end
      it 'return http success' do
        member = ::Lbaas2::FakeFactory.new.update_member
        put :update, params: default_params.merge({id: member[:id], member: member})
        expect(response).to be_successful
      end
    end
    context 'cloud_network_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'cloud_network_admin' }
          token
        end
      end
      it 'return http success' do
        member = ::Lbaas2::FakeFactory.new.update_member
        put :update, params: default_params.merge({id: member[:id], member: member})
        expect(response).to be_successful
      end
    end
    context 'member' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'member' }
          token
        end
      end
      it 'return http success' do
        member = ::Lbaas2::FakeFactory.new.update_member
        put :update, params: default_params.merge({id: member[:id], member: member})
        expect(response).to be_successful
      end
    end
    context 'loadbalancer_poolmemberadmin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_poolmemberadmin' }
          token
        end
      end
      it 'return http success' do
        member = ::Lbaas2::FakeFactory.new.update_member
        put :update, params: default_params.merge({id: member[:id], member: member})
        expect(response).to be_successful
      end
    end
    context 'network_viewer' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
          token
        end
      end
      it 'return 401 error' do
        member = ::Lbaas2::FakeFactory.new.update_member
        put :update, params: default_params.merge({id: member[:id], member: member})
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
    context 'loadbalancer_viewer' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_viewer' }
          token
        end
      end
      it 'return 401 error' do
        member = ::Lbaas2::FakeFactory.new.update_member
        put :update, params: default_params.merge({id: member[:id], member: member})
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
    context 'empty network roles' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token
        end
      end
      it 'return 401 error' do
        member = ::Lbaas2::FakeFactory.new.update_member
        put :update, params: default_params.merge({id: member[:id], member: member})
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end

  describe "POST 'create'" do
    before :each do
      member = double('elektron', service: double("octavia", get: double("get", map_to: double("lb", vip_subnet_id: "some_id", to_json:{})), post: double("post", body: {}) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(member)
      allow_any_instance_of(Lbaas2::Loadbalancers::Pools::MembersController).to receive(:parseMemberParams).and_return(::Lbaas2::FakeFactory.new.member_params)
    end

    context 'network_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
          token
        end
      end
      it 'return http success' do
        member = ::Lbaas2::FakeFactory.new.member
        post :create, params: default_params.merge({member: member})
        expect(response).to be_successful
      end
    end
    context 'loadbalancer_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_admin' }
          token
        end
      end
      it 'return http success' do
        member = ::Lbaas2::FakeFactory.new.member
        post :create, params: default_params.merge({member: member})
        expect(response).to be_successful
      end
    end
    context 'cloud_network_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'cloud_network_admin' }
          token
        end
      end
      it 'return http success' do
        member = ::Lbaas2::FakeFactory.new.member
        post :create, params: default_params.merge({member: member})
        expect(response).to be_successful
      end
    end
    context 'member' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'member' }
          token
        end
      end
      it 'return http success' do
        member = ::Lbaas2::FakeFactory.new.member
        post :create, params: default_params.merge({member: member})
        expect(response).to be_successful
      end
    end
    context 'loadbalancer_poolmemberadmin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_poolmemberadmin' }
          token
        end
      end
      it 'return http success' do
        member = ::Lbaas2::FakeFactory.new.member
        post :create, params: default_params.merge({member: member})
        expect(response).to be_successful
      end
    end
    context 'network_viewer' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
          token
        end
      end
      it 'return 401 error' do
        member = ::Lbaas2::FakeFactory.new.member
        post :create, params: default_params.merge({member: member})
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
    context 'loadbalancer_viewer' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_viewer' }
          token
        end
      end
      it 'return 401 error' do
        member = ::Lbaas2::FakeFactory.new.member
        post :create, params: default_params.merge({member: member})
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
    context 'empty network roles' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token
        end
      end
      it 'return 401 error' do
        member = ::Lbaas2::FakeFactory.new.member
        post :create, params: default_params.merge({member: member})
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end

  describe "DELETE 'destroy'" do
    before :each do
      member = double('elektron', service: double("octavia", delete: double("delete") ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(member)
    end

    context 'network_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
          token
        end
      end
      it 'return http success' do
        delete :destroy, params: default_params.merge(id: 'member_id')
        expect(response).to be_successful
      end
    end
    context 'loadbalancer_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_admin' }
          token
        end
      end
      it 'return http success' do
        delete :destroy, params: default_params.merge(id: 'member_id')
        expect(response).to be_successful
      end
    end
    context 'cloud_network_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'cloud_network_admin' }
          token
        end
      end
      it 'return http success' do
        delete :destroy, params: default_params.merge(id: 'member_id')
        expect(response).to be_successful
      end
    end
    context 'member' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'member' }
          token
        end
      end
      it 'return http success' do
        delete :destroy, params: default_params.merge(id: 'member_id')
        expect(response).to be_successful
      end
    end
    context 'loadbalancer_poolmemberadmin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_poolmemberadmin' }
          token
        end
      end
      it 'return http success' do
        delete :destroy, params: default_params.merge(id: 'member_id')
        expect(response).to be_successful
      end
    end
    context 'network_viewer' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
          token
        end
      end
      it 'return 401 error' do
        delete :destroy, params: default_params.merge(id: 'member_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
    context 'loadbalancer_viewer' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_viewer' }
          token
        end
      end
      it 'return 401 error' do
        delete :destroy, params: default_params.merge(id: 'member_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
    context 'no network roles' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token
        end
      end

      it 'return 401 error' do
        delete :destroy, params: default_params.merge(id: 'member_id')
        expect(response.code).to be == ("401")
        expect(response).to_not be_successful
      end
    end
  end

  describe "GET 'serversForSelect'" do
    before :each do
      allow_any_instance_of(ServiceLayer::KeyManagerService).to receive(:containers).and_return([])
      allow_any_instance_of(ServiceLayer::ComputeService).to receive(:servers).and_return([])
    end

    it_behaves_like 'GET action with editor context including loadbalancer_poolmemberadmin' do
      subject do
        @default_params = default_params
        @extra_params = {}
        @path = "serversForSelect"
      end
    end

  end

end