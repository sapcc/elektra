shared_examples_for "an authenticated_user controller" do
  include AuthenticationStub

  before :each do
    stub_auth_configuration
  end

  context "domain_id is provided" do

    default_params = {domain_fid: AuthenticationStub.domain_id}

    before(:all) do
      DatabaseCleaner.clean
      @domain = create(:domain, key: default_params[:domain_fid])
    end

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
        expect(request.params.values_at(:domain_fid)).to eq(default_params.values_at(:domain_fid))
      end

      it "redirects to login form if domain is changed and domain exists" do
        @bad_domain = create(:domain, key: 'BAD_DOMAIN')
        get :index, domain_fid: 'BAD_DOMAIN'
        expect(response).to redirect_to(controller.monsoon_openstack_auth.new_session_path)
      end

      it "throws exception if domain is changed and domain NOT exists" do
        get :index, domain_fid: 'SUPER_BAD_DOMAIN'
        expect(response).to render_template("application/error")
      end
    end
  end

  context "domain_id and project_id are provided" do

    default_params = {domain_fid: AuthenticationStub.domain_id, project_fid: AuthenticationStub.project_id}

    before(:all) do
      DatabaseCleaner.clean
      @domain = create(:domain, key: default_params[:domain_fid])
      @project = create(:project, key: default_params[:project_fid], domain: @domain)
    end

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
        expect(request.params.values_at(:domain_fid, :project_fid)).to eq(default_params.values_at(:domain_fid, :project_fid))
      end
    end
  end

end