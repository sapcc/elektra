require 'spec_helper'
require_relative '../factories/factories'

describe EmailService::ConfigsetsController, type: :controller do
  routes { EmailService::Engine.routes }

  default_params = { domain_id: AuthenticationStub.domain_id,
                     project_id: AuthenticationStub.project_id }

  before(:all) do
    FriendlyIdEntry.find_or_create_entry(
      'Domain', nil, default_params[:domain_id], 'default'
    )
    FriendlyIdEntry.find_or_create_entry(
      'Project', default_params[:domain_id], default_params[:project_id],
      default_params[:project_id]
    )
    puts "\n ==============================================================\n"
    puts "\n [ConfigsetsController] \n"
    puts "\n ==============================================================\n"
  end

  before :each do
    allow(UserProfile).to receive(:tou_accepted?).and_return(true)
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:check_ec2_creds_cronus_status).and_return(double('render').as_null_object)
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:check_verified_identity).and_return(double('render').as_null_object)
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:ec2_creds).and_return(double('creds').as_null_object)
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:ses_client_v2).and_return(double('ses_client_v2').as_null_object)
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:ses_client).and_return(double('ses_client').as_null_object)
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:list_configsets).and_return(double('config_sets').as_null_object)
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:new_configset).and_return(double('config_set').as_null_object)
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:describe_configset).and_return(double('config_set').as_null_object)
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:store_configset).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:delete_configset).and_return(double('status').as_null_object)

  end


  # check index route
  describe "GET 'index'" do

    # check email admin role
    context 'email_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'email_service_role', 'name' => 'email_admin' }
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http success' do
        get :index, params: default_params
        expect(response).to be_successful
      end
    end

    # check email user role
    context 'email_user' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'email_service_role', 'name' => 'email_user' }
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http success' do
        get :index, params: default_params
        expect(response).to be_successful
      end
    end

    context 'cloud_support_tools_viewer_role alone' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http status 401' do
        get :index, params: default_params
        expect(response).to render_template('application/exceptions/warning.html')
      end
    end

  end

  # GET new
  describe "GET 'new'" do

    context 'email_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'email_service_role', 'name' => 'email_admin' }
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http 200 status' do
        get :new, params: default_params
        expect(response).to have_http_status(200)
        expect(response).to render_template(:new)
      end
    end

    context 'email_user' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'email_service_role', 'name' => 'email_user' }
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http 200 status' do
        get :new, params: default_params
        expect(response).to have_http_status(200)
        expect(response).to render_template(:new)
      end
    end

    context 'cloud_support_tools_viewer_role alone' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http 401 status' do
        get :new, params: default_params
        expect(response).to render_template('application/exceptions/warning.html')
      end
    end


  end


  # POST create
  describe "POST 'create'" do

    before :each do
      @configset_opts = ::EmailService::FakeFactory.new.configset_opts
    end

    puts "\n ==============================================================\n"
    puts "\n [ConfigsetsController][create] \n"
    puts "\n  @configset_opts : #{@configset_opts} \n"
    puts "\n ==============================================================\n"

    context 'email_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'email_service_role', 'name' => 'email_admin' }
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http 302 status' do
        expect(post(:create, params: default_params.merge(opts: @configset_opts))).to have_http_status(302)
      end
    end

    context 'email_user' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'email_service_role', 'name' => 'email_user' }
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http 302 status' do
        expect(post(:create, params: default_params.merge(opts: @configset_opts))).to have_http_status(302)
      end
    end

    context 'cloud_support_tools_viewer_role alone' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http 401 status' do
        post(:create, params: default_params.merge(opts: @configset_opts))
        expect(response).to render_template('application/exceptions/warning.html')
      end
    end

  end



  # DELETE destroy
  describe "DELETE 'destroy'" do

    before :each do
      @configset_opts = ::EmailService::FakeFactory.new.configset_opts
    end

    context 'email_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'email_service_role', 'name' => 'email_admin' }
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http 302 status' do
        delete(:destroy, params: default_params.merge(id: @configset_opts[:id]))
        expect(response).to redirect_to(configsets_path(default_params))
        expect(response.code).to eq("302")
      end
    end

    context 'email_user' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'email_service_role', 'name' => 'email_user' }
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http 302 status' do
        delete(:destroy, params: default_params.merge(id: @configset_opts[:id]))
        expect(response).to redirect_to(configsets_path(default_params))
        expect(response.code).to eq("302")
      end
    end

    context 'cloud_support_tools_viewer_role alone' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http 401 status' do
        delete(:destroy, params: default_params.merge(id: @configset_opts[:id]))
        expect(response).to render_template('application/exceptions/warning.html')
      end
    end

  end

end
