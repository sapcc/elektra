require 'spec_helper'
require_relative '../factories/factories'

describe EmailService::TemplatedEmailsController, type: :controller do
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
    allow_any_instance_of(EmailService::TemplatedEmailsController).to receive(:check_ec2_creds_cronus_status).and_return(double('redirect_path').as_null_object)
    allow_any_instance_of(EmailService::TemplatedEmailsController).to receive(:list_verified_identities).and_return(double('identities').as_null_object)
    allow_any_instance_of(EmailService::TemplatedEmailsController).to receive(:get_verified_identities_by_status).and_return(double('statuses').as_null_object)           
    allow_any_instance_of(EmailService::TemplatedEmailsController).to receive(:get_send_data).and_return(double('data').as_null_object)            
    allow_any_instance_of(EmailService::TemplatedEmailsController).to receive(:get_verified_identities_collection).and_return(double('verified_identities').as_null_object)
    allow_any_instance_of(EmailService::TemplatedEmailsController).to receive(:get_all_templates).and_return(double('templates').as_null_object)
    allow_any_instance_of(EmailService::TemplatedEmailsController).to receive(:get_templates_collection).and_return(double('templates').as_null_object)
    allow_any_instance_of(EmailService::TemplatedEmailsController).to receive(:list_configset_names).and_return(double('configsets').as_null_object) 
    allow_any_instance_of(EmailService::TemplatedEmailsController).to receive(:send_templated_email).and_return(double('status').as_null_object) 
  end

  # GET New
  describe "GET 'New'" do

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
        expect(response).to render_template('email_service/shared/role_warning.html')
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
        expect(response).to render_template('email_service/shared/role_warning.html')
      end
    end
  end

  # POST create
  describe "POST 'create'" do
    before :each do
      @opts = ::EmailService::FakeFactory.new.templated_email_opts
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
      it 'render#edit' do
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
      it 'render#edit' do
        expect(post(:create, params: default_params.merge(opts: @opts))).to have_http_status(200)
      end
    end

    context 'cloud_support_tools_viewer_role#only' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http 401 status' do
        expect(post(:create, params: default_params.merge(opts: @opts))).to render_template('email_service/shared/role_warning.html')
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
        expect(post(:create, params: default_params.merge(opts: @opts))).to render_template('email_service/shared/role_warning.html')
      end
    end

  end



end
