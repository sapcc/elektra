# frozen_string_literal: true

require 'spec_helper'
require_relative './factories/factories.rb'
require_relative 'shared'

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

    it_behaves_like 'index action' do
      subject do
        @default_params = default_params
      end
    end

  end

  describe "GET 'show'" do
    before :each do
      l7policy = double('elektron', service: double("octavia", get: double("get", map_to: double("l7policy", to_json:{})) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(l7policy)
    end

    it_behaves_like 'show action' do
      subject do
        @default_params = default_params
      end
    end

  end

  describe "POST 'create'" do
    before :each do
      l7policy = double('elektron', service: double("octavia", post: double("post", body: {}) ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(l7policy)
    end

    it_behaves_like 'post action' do
      subject do
        @default_params = default_params
        @extra_params = {l7policy: ::Lbaas2::FakeFactory.new.l7policy}
      end
    end

  end

  describe "DELETE 'destroy'" do
    before :each do
      policy = double('elektron', service: double("octavia", delete: double("delete") ))
      allow_any_instance_of(ServiceLayer::Lbaas2Service).to receive(:elektron).and_return(policy)
    end


    it_behaves_like 'destroy action' do
      subject do
        @default_params = default_params
        @extra_params = {id: 'policy_id'}
      end
    end

  end

end