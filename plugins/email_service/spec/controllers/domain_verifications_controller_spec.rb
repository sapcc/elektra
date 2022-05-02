require 'spec_helper'
require_relative '../factories/factories'

describe EmailService::DomainVerificationsController, type: :controller do
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
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:ec2_creds).and_return(double('creds').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:check_ec2_creds_cronus_status).and_return(double('redirect_path').as_null_object) 
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:list_verified_identities).and_return(double('identities').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:get_verified_identities_by_status).and_return(double('status').as_null_object)     
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:remove_verified_identity).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:verify_dkim).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:activate_dkim).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:deactivate_dkim).and_return(double('status').as_null_object)
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
      it 'returns http 401 status' do
        get :index, params: default_params
        expect(response).to render_template('application/exceptions/warning')
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
        expect(response).to render_template('application/exceptions/warning')
      end
    end

  end



  # check new route
  describe "GET 'new'" do
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
        get :new, params: default_params
        expect(response).to be_successful
        expect(response).to render_template(:new)
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
        get :new, params: default_params
        expect(response).to be_successful
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

    context 'other roles' do
      before :each do
        stub_authentication do |token|
          token['roles'].delete_if { |h| h['id'] == 'email_service_role' }
          token
        end
      end
      it 'not allowed' do
        get :new, params: default_params
        expect(response).to render_template('application/exceptions/warning')
      end
    end

  end


  # check create route
  describe "POST 'create'" do
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
        post :create, params: default_params
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
        post :create, params: default_params
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
      it 'returns http 401 status' do
        post :create, params: default_params
        expect(response).to render_template('application/exceptions/warning')
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
        post :create, params: default_params
        expect(response).to render_template('application/exceptions/warning')
      end
    end

  end


  # check delete route
  describe "DELETE#destroy" do
    before :each do 
      @opts = EmailService::FakeFactory.new.verfied_domain_opts
    end
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
        delete :destroy, params: default_params.merge(id: @opts[:id])
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
        delete :destroy, params: default_params.merge(id: @opts[:id])
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
      it 'returns http 401 status' do
        delete :destroy, params: default_params.merge(id: @opts[:id])
        expect(response).to render_template('application/exceptions/warning')
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
        delete :destroy, params: default_params.merge(id: @opts[:id])
        expect(response).to render_template('application/exceptions/warning')
      end
    end

  end

  # check verify_dkim route
  describe "verify_dkim" do
    before :each do 
      @opts = EmailService::FakeFactory.new.verfied_domain_opts
    end
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
        post :verify_dkim, params: default_params.merge(id: @opts[:id])
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
        post :verify_dkim, params: default_params.merge(id: @opts[:id])
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
      it 'returns http 401 status' do
        post :verify_dkim, params: default_params.merge(id: @opts[:id])
        expect(response).to render_template('application/exceptions/warning')
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
        post :verify_dkim, params: default_params.merge(id: @opts[:id])
        expect(response).to render_template('application/exceptions/warning')
      end
    end

  end

  # check post#activate_dkim route
  describe "POST#activate_dkim" do
    before :each do 
      @opts = EmailService::FakeFactory.new.verfied_domain_opts
    end
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
        post :activate_dkim, params: default_params.merge(id: @opts[:id])
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
        post :activate_dkim, params: default_params.merge(id: @opts[:id])
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
      it 'returns http 401 status' do
        post :activate_dkim, params: default_params.merge(id: @opts[:id])
        expect(response).to render_template('application/exceptions/warning')
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
        post :activate_dkim, params: default_params.merge(id: @opts[:id])
        expect(response).to render_template('application/exceptions/warning')
      end
    end

  end

  # check post#deactivate_dkim route
  describe "POST#deactivate_dkim" do
    before :each do 
      @opts = EmailService::FakeFactory.new.verfied_domain_opts
    end
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
        post :deactivate_dkim, params: default_params.merge(id: @opts[:id])
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
        post :deactivate_dkim, params: default_params.merge(id: @opts[:id])
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
      it 'returns http 401 status' do
        post :deactivate_dkim, params: default_params.merge(id: @opts[:id])
        expect(response).to render_template('application/exceptions/warning')
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
        post :deactivate_dkim, params: default_params.merge(id: @opts[:id])
        expect(response).to render_template('application/exceptions/warning')
      end
    end

  end

end