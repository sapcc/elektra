shared_examples_for "an authenticated_user controller" do
  include AuthenticationStub

  before :each do
    stub_auth_configuration
  end

  context "domain_id is provided" do

    default_params = {domain_id: AuthenticationStub.domain_id}

    before(:all) do
      DatabaseCleaner.clean
      @domain = create(:domain, key: default_params[:domain_id])
    end

    before :each do
      stub_authentication
      
      # stub api connection for domains
      service_user = double("service_user").as_null_object
      domains = double("domains").as_null_object
      allow(domains).to receive(:find_by_id).and_raise "Not found"
      allow(domains).to receive(:all).and_return([])
      allow(service_user).to receive(:domains).and_return(domains)
      allow_any_instance_of(Openstack::AdminIdentityService).to receive(:service_user).and_return(service_user)
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

      it "redirects to friendly url" do
        @bad_domain = create(:domain, key: 'BAD_DOMAIN')
        get :index, domain_id: 'BAD_DOMAIN'
        expect(response).to redirect_to(controller.url_for(controller.params.merge(domain_id: 'bad_domain')))
      end
      
      it "render error if domain has changed and domain exists and user is not authorized" do
        @bad_domain = create(:domain, key: 'BAD_DOMAIN')
        get :index, domain_id: 'bad_domain'
        expect(response).to render_template('authenticated_user/error')
      end

      it "throws exception if domain is changed and domain NOT exists" do
        get :index, domain_id: 'SUPER_BAD_DOMAIN'
        expect(response).to render_template("application/error")
      end
    end
  end

  context "domain_id and project_id are provided" do

    default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}

    before(:all) do
      DatabaseCleaner.clean
      @domain = create(:domain, key: default_params[:domain_id])
      @project = create(:project, key: default_params[:project_id], domain: @domain)
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
        expect(request.params.values_at(:domain_id, :project_id)).to eq(default_params.values_at(:domain_id, :project_id))
      end
    end
  end

end