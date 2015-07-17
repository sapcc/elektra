require 'spec_helper'

describe ServicesController do

  default_params = {domain_fid: AuthenticationStub.domain_id}

  before(:all) do
    DatabaseCleaner.clean
    @domain = create(:domain, key: default_params[:domain_fid])
    @project = create(:project, key: default_params[:project_fid], domain: @domain)
  end


  describe "GET 'index'" do
    it "returns http success" do
      get 'index', default_params
      expect(response).to be_success
    end
  end

end
