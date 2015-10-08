require 'spec_helper'
require 'controllers/dashboard/shared_examples'
require 'controllers/dashboard/stub_identity_service'

describe Dashboard::NetworksController do
  include AuthenticationStub
  include StubIdentityService
  
  # it_behaves_like "an dashboard controller"
  #
  # default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}
  #
  # before(:all) do
  #   DatabaseCleaner.clean
  #   @domain = create(:domain, key: default_params[:domain_id])
  #   @project = create(:project, key: default_params[:project_id], domain: @domain)
  # end
  #
  # describe "GET #index" do
  #   it "returns http success" do
  #     get :index, default_params
  #     expect(response).to have_http_status(:success)
  #   end
  # end

end
