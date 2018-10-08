require 'spec_helper'

describe Audit::ApplicationController, type: :controller do
  routes { Audit::Engine.routes }

  default_params = { domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id }

  before(:all) do
    FriendlyIdEntry.find_or_create_entry('Domain', nil, default_params[:domain_id], 'default')
    FriendlyIdEntry.find_or_create_entry('Project', default_params[:domain_id], default_params[:project_id], default_params[:project_id])
  end

  before :each do
    stub_authentication do |token|
      token['roles'].delete_if { |h| h['id'] == 'audit_role' }
      token['roles'] << { 'id' => 'audit_role', 'name' => 'audit_viewer' }
      token
    end
  end

  describe "GET 'index'" do
    it 'returns http success' do
      get :index, params: default_params
      expect(response).to be_success
    end
  end
end
