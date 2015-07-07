require 'spec_helper'

describe ServicesController do

  default_params = {domain_id: AuthenticationStub.domain_id}

  describe "GET 'index'" do
    it "returns http success" do
      get 'index', default_params
      expect(response).to be_success
    end
  end

end
