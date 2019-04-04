require 'spec_helper'

describe Identity::CredentialsController, type: :controller do
  routes { Identity::Engine.routes }
  default_params = { domain_id: AuthenticationStub.domain_id }

  before(:all) do
    FriendlyIdEntry.find_or_create_entry('Domain', nil,
                                         default_params[:domain_id], 'default')
  end

  before(:each) do
    stub_authentication

    allow_any_instance_of(ServiceLayer::IdentityService)
      .to receive(:credentials).and_return([])
  end

  describe "GET 'index'" do
    it 'sreturns http success' do
      get :index, params: default_params
      expect(response).to be_successful
    end
  end
end
