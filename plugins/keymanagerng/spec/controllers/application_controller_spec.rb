# frozen_string_literal: true

require 'spec_helper'

describe Keymanagerng::ApplicationController, type: :controller do
  routes { Keymanagerng::Engine.routes }

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
  end

  describe 'GET user_name' do
    
    it 'returns http success' do
      allow(controller.cloud_admin).to receive(:find_user).and_return(
        double("user", name: "test_user"),
      )
      extra_params = { user_id: 'user_123456789' }
      get :user_name, params: default_params.merge(extra_params)
      expect(response).to be_successful
    end
  end
end
