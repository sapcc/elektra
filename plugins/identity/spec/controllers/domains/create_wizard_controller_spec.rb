# frozen_string_literal: true

require 'spec_helper'

describe Identity::Domains::CreateWizardController, type: :controller do
  routes { Identity::Engine.routes }

  default_params = { domain_id: AuthenticationStub.domain_id }

  before(:all) do
    FriendlyIdEntry.find_or_create_entry(
      'Domain', nil, default_params[:domain_id], 'default'
    )
  end

  before(:each) do
    stub_authentication
  end

  describe 'GET index' do
    it 'returns http success' do
      get :new, params: default_params
      expect(response).to be_successful
    end
  end

end
