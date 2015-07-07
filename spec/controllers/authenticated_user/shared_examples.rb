shared_examples_for "an authenticated_user controller" do
  include AuthenticationStub

  default_params = {domain_id: AuthenticationStub.domain_id}

  before :each do
    stub_auth_configuration  
  end

  context "domain_id is provided" do
    default_params = {domain_id: AuthenticationStub.domain_id}
    before :each do
      stub_authentication
    end

    describe "GET 'index'" do
      it "returns http success" do
        get :index, default_params
        expect(response).to be_success
      end

      it "gets domain_id and project_id" do
        get :index, default_params
        expect(request.params.values_at(:domain_id)).to eq(default_params.values_at(:domain_id))
      end

      it "redirects to login form" do
        get :index, domain_id: 'BAD_DOMAIN'
        expect(response).to redirect_to(controller.monsoon_openstack_auth.new_session_path)
      end
    end
  end

  context "domain_id and project_id are provided" do
    default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}
    before :each do
      stub_authentication
    end

    describe "GET 'index'" do
      it "returns http success" do
        get :index, default_params
        expect(response).to be_success
      end

      it "gets domain_id and project_id" do
        get :index, default_params
        expect(request.params.values_at(:domain_id,:project_id)).to eq(default_params.values_at(:domain_id,:project_id))
      end
    end
  end
  
end