require 'spec_helper'
require_relative '../factories/factories'

describe EmailService::TemplatesController, type: :controller do
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
    allow(UserProfile).to receive(:tou_accepted?).and_return(true)
    allow_any_instance_of(EmailService::TemplatesController).to receive(:check_ec2_creds_cronus_status).and_return(double('redirect_path').as_null_object)
    allow_any_instance_of(EmailService::TemplatesController).to receive(:ec2_creds).and_return(double('redirect_path').as_null_object)
    allow_any_instance_of(EmailService::TemplatesController).to receive(:store_template).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::TemplatesController).to receive(:update_template).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::TemplatesController).to receive(:list_templates).and_return(double('templates').as_null_object)
    allow_any_instance_of(EmailService::TemplatesController).to receive(:delete_template).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::TemplatesController).to receive(:find_template).and_return(double('template').as_null_object)
    allow_any_instance_of(EmailService::TemplatesController).to receive(:get_all_templates).and_return(double('templates').as_null_object)
    allow_any_instance_of(EmailService::TemplatesController).to receive(:get_templates_collection).and_return(double('temp_collection').as_null_object)
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

    context 'other roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'email_service_role' }
          token
        end
      end
      it 'not allowed' do
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

    context 'other roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'email_service_role' }
          token
        end
      end
      it 'not allowed' do
        get :new, params: default_params
        expect(response).to render_template('application/exceptions/warning.html')
      end
    end

  end


  # POST create
  describe "POST 'create'" do

    before :each do
      @opts = ::EmailService::FakeFactory.new.template_opts
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
        expect(post(:create, params: default_params.merge(opts: @opts))).to have_http_status(200)
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
        expect(post(:create, params: default_params.merge(opts: @opts))).to have_http_status(200)
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
        expect(post(:create, params: default_params.merge(opts: @opts))).to render_template('application/exceptions/warning.html')
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
        expect(post(:create, params: default_params.merge(opts: @opts))).to render_template('application/exceptions/warning.html')
      end
    end

  end



  # DELETE destroy
  describe "DELETE 'destroy'" do

    before :each do
      @opts = ::EmailService::FakeFactory.new.template_opts
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
        expect(delete(:destroy, params: default_params.merge(id: @opts[:id]))).to redirect_to(templates_path(default_params))
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
        expect(delete(:destroy, params: default_params.merge(id: @opts[:id]))).to redirect_to(templates_path(default_params))
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
        expect(delete(:destroy, params: default_params.merge(id: @opts[:id]))).to render_template('application/exceptions/warning.html')
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
        expect(delete(:destroy, params: default_params.merge(id: @opts[:id]))).to render_template('application/exceptions/warning.html')
      end
    end

  end

end
