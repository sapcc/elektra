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
  end
  before :each do
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:list_configsets).and_return(double('config_sets').as_null_object)            
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:get_ec2_creds).and_return(double('creds').as_null_object)
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:new_configset).and_return(double('config_set').as_null_object)
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:store_configset).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::ConfigsetsController).to receive(:delete_configset).and_return(double('status').as_null_object)
    
  end
      

  # check index route
  describe "GET 'index'" do
 
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
 
    context 'with cloud_support_tools_viewer_role' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }         
          token
        end
      end
      it 'returns http status 401' do
        get :index, params: default_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'other roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'email_service_role' }
          token
        end
      end
      it 'not allowed' do
        get :index, params: default_params
        expect(response).to_not be_successful
      end
    end

  end


  # check new route
  describe "GET 'new'" do
 
    context 'email_admin role' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'email_service_role', 'name' => 'email_admin' }
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }         
          token
        end
      end
      it 'returns http success' do
        get :new, params: default_params
        expect(response).to be_successful
        expect(response).to render_template(:new)
      end
    end

    context 'email_user role' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'email_service_role', 'name' => 'email_user' }
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }         
          token
        end
      end
      it 'returns http success' do
        get :new, params: default_params
        expect(response).to be_successful
        expect(response).to render_template(:new)
      end
    end
 
    context 'with cloud_support_tools_viewer_role' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }         
          token
        end
      end
      it 'returns http status 401' do
        get :new, params: default_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'other roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'email_service_role' }
          token
        end
      end
      it 'not allowed' do
        get :new, params: default_params
        expect(response).to_not be_successful
      end
    end

  end

  # check create route
  describe "POST 'create'" do

    before :each do
      @configset = ::EmailService::FakeFactory.new.configset_opts
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
      it 'returns redirects status' do
        expect(post(:create, params: default_params.merge(configset: @configset))).to have_http_status(200) #redirect_to(configsets_path(default_params))
        expect(response.code).to eq("200")
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
      
      it 'returns http success' do
        # configset = ::EmailService::FakeFactory.new.configset
        # controller.instance_variable_set(:@configset, configset)
        # cfg = controller.instance_variable_get(:@configset)
        post :create, params: default_params.merge(configset: @configset)
        expect(response).to have_http_status(200)
        expect(response).to render_template(:edit)
      end
    end
  
    context 'with cloud_support_tools_viewer_role' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }         
          token
        end
      end
      it 'returns http status 401' do
        post :create, params: default_params.merge(configset: @configset)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'other roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'email_service_role' }
          token
        end
      end
      it 'not allowed' do
        post :create, params: default_params.merge(configset: @configset)
        expect(response).to_not be_successful
      end
    end

  end


  # check destroy route
  describe "DELETE 'destroy'" do

    before :each do
      @configset = ::EmailService::FakeFactory.new.configset_opts
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
      it 'returns http redirect' do
        configset = ::EmailService::FakeFactory.new.configset_opts
        delete :destroy, params: default_params.merge(id: @configset[:id])
        expect(response).to have_http_status(302)
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
      it 'returns http redirect' do
        # configset = ::EmailService::FakeFactory.new.configset_opts
        delete :destroy, params: default_params.merge(id: @configset[:id])
        expect(response).to have_http_status(302)
      end
    end
  
    context 'with cloud_support_tools_viewer_role' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }         
          token
        end
      end
      it 'returns http status 401' do
        # configset = ::EmailService::FakeFactory.new.configset_opts
        delete :destroy, params: default_params.merge(id: @configset[:id])
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'other roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'email_service_role' }
          token
        end
      end
      it 'not allowed' do
        # configset = ::EmailService::FakeFactory.new.configset_opts
        delete :destroy, params: default_params.merge(id: @configset[:id])
        expect(response).to_not be_successful
      end
    end

  end


end
