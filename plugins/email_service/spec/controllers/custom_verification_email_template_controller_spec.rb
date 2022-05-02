require 'spec_helper'
require_relative '../factories/factories'

describe EmailService::CustomVerificationEmailTemplatesController, type: :controller do
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
    allow_any_instance_of(EmailService::CustomVerificationEmailTemplatesController).to receive(:check_ec2_creds_cronus_status).and_return(double('render').as_null_object)
    allow_any_instance_of(EmailService::CustomVerificationEmailTemplatesController).to receive(:ec2_creds).and_return(double('creds').as_null_object)
    allow_any_instance_of(EmailService::CustomVerificationEmailTemplatesController).to receive(:create_custom_verification_email_template).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::CustomVerificationEmailTemplatesController).to receive(:delete_custom_verification_email_template).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::CustomVerificationEmailTemplatesController).to receive(:update_custom_verification_email_template).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::CustomVerificationEmailTemplatesController).to receive(:custom_templates).and_return(double('custom_templates').as_null_object)
    allow_any_instance_of(EmailService::CustomVerificationEmailTemplatesController).to receive(:list_custom_verification_email_templates).and_return(double('custom_templates').as_null_object)
    allow_any_instance_of(EmailService::CustomVerificationEmailTemplatesController).to receive(:find_custom_verification_email_template).and_return(double('custom_template').as_null_object)
  
    # nebula_details
    # nebula_status
    # nebula_active?
    # nebula_activate
    # nebula_available?
    # nebula_deactivate

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
        expect(response).to render_template('application/exceptions/warning')
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
        expect(response).to render_template('application/exceptions/warning')
      end
    end


  end


  # POST create
  describe "POST 'create'" do

    before :each do
      @opts = ::EmailService::FakeFactory.new.custom_verification_email_template_opts
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
        expect(post(:create, params: default_params.merge(opts: @opts))).to render_template('application/exceptions/warning')
      end
    end

  end



  # DELETE destroy
  describe "DELETE 'destroy'" do

    before :each do
      @opts = ::EmailService::FakeFactory.new.custom_verification_email_template_opts
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
        expect(delete(:destroy, params: default_params.merge(id: @opts[:id]))).to redirect_to(custom_verification_email_templates_path(default_params))
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
        expect(delete(:destroy, params: default_params.merge(id: @opts[:id]))).to redirect_to(custom_verification_email_templates_path(default_params))
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
        expect(delete(:destroy, params: default_params.merge(id: @opts[:id]))).to render_template('application/exceptions/warning')
      end
    end

  end

end
