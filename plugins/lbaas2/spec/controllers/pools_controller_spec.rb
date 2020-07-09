
require 'spec_helper'
require_relative './factories/factories.rb'
require_relative 'shared'

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

    it_behaves_like 'index action' do
      subject do
        @default_params = default_params
      end
    end
    
  end

  describe "GET 'show'" do
    before :each do
      pool = double('elektron', service: double("octavia", get: double("get", map_to: double("pool", to_json:{})) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(pool)
      allow_any_instance_of(Lbaas2::Loadbalancers::PoolsController).to receive(:extend_pool_data).and_return(double('cached_pools').as_null_object)
    end

    it_behaves_like 'show action' do
      subject do
        @default_params = default_params
      end
    end

  end

  describe "POST 'create'" do
    before :each do
      pool = double('elektron', service: double("octavia", post: double("post", body: {}) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(pool)
      allow_any_instance_of(Lbaas2::Loadbalancers::PoolsController).to receive(:extend_pool_data).and_return(double('cached_pools').as_null_object)
    end

    it_behaves_like 'post action' do
      subject do
        @default_params = default_params
        @extra_params = {pool: ::Lbaas2::FakeFactory.new.pool}
      end
    end

  end

  describe "PUT 'update'" do
    before :each do
      pool = double('elektron', service: double("octavia", get: double("get", map_to: double("pool", to_json:{}, update_attributes: {}, update:{})),  put: double("put", body: {}) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(pool)
      allow_any_instance_of(Lbaas2::Loadbalancers::PoolsController).to receive(:extend_pool_data).and_return(double('cached_pools').as_null_object)
    end

    it_behaves_like 'PUT action' do
      subject do
        @default_params = default_params
        pool = ::Lbaas2::FakeFactory.new.update_pool
        @extra_params = {id: pool[:id], pool: pool}
      end
    end
  end

  describe "DELETE 'destroy'" do
    before :each do
      pool = double('elektron', service: double("octavia", delete: double("delete") ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(pool)
    end


    it_behaves_like 'destroy action' do
      subject do
        @default_params = default_params
        @extra_params = {id: 'pool_id'}
      end
    end

  end

  describe "GET 'itemsForSelect'" do
    before :each do
      pools = double('elektron', service: double("octavia", get: double("get", map_to: []) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(pools)
    end

    it_behaves_like 'GET action with editor context' do
      subject do
        @default_params = default_params
        @extra_params = {}
        @path = "itemsForSelect"
      end
    end

  end
end