require 'spec_helper'

describe ServicesController do

  default_params = {domain_id: AuthenticationStub.domain_id}

  before(:all) do
    DatabaseCleaner.clean
    @domain = create(:domain, key: default_params[:domain_id])
    @project = create(:project, key: default_params[:project_id], domain: @domain)
  end


  describe "GET 'index'" do
    it "returns http success" do
      get 'index', default_params
      expect(response).to be_success
    end
  end

end
