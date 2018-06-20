# frozen_string_literal: true

require 'spec_helper'

describe Reports::CostController, type: :controller do
  # render_views
  routes { Reports::Engine.routes }

  default_params = { domain_id: AuthenticationStub.domain_id,
                     project_id: AuthenticationStub.project_id }

  before(:all) do
    FriendlyIdEntry.find_or_create_entry('Domain', nil,
                                         default_params[:domain_id], 'default')
    FriendlyIdEntry.find_or_create_entry('Project',
                                         default_params[:domain_id],
                                         default_params[:project_id],
                                         default_params[:project_id])
  end

  before :each do
    stub_authentication
    allow(UserProfile).to receive(:tou_accepted?).and_return true
  end

  describe 'GET index' do
    context 'html' do
      it 'returns http success' do
        get :index, params: default_params
        expect(response).to be_success
      end
    end
    context 'json' do
      before :each do
        request.headers['accept'] = 'application/json'
      end

      it 'returns http success' do
        allow_any_instance_of(ServiceLayer::MasterdataCockpitService).to receive(:get_project_costing).and_return(test: 'test')
        get :index, params: default_params
        expect(response).to be_success
        body = JSON.parse(response.body)
        expect(body['test']).to eq('test')
      end
    end
  end
end
