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

    puts "\n ==============================================================\n"
    puts "\n [DomainVerificationsController] \n"
    puts "\n ==============================================================\n"

  end

  before :each do
    allow(UserProfile).to receive(:tou_accepted?).and_return(true)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:ec2_creds).and_return(double('creds').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:list_configsets).and_return(double('configsets').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:ses_client_v2).and_return(double('ses_client_v2').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:ses_client).and_return(double('ses_client').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:verified_domain).and_return(double('verified_domain').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:domains).and_return(double('domains').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:list_configset_names).and_return(double('configset_names').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:check_ec2_creds_cronus_status).and_return(double('redirect_path').as_null_object)
    # allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:check_verified_identity).and_return(double('redirect_path').as_null_object)
    # allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:list_verified_identities).and_return(double('identities').as_null_object)
    # allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:get_verified_identities_by_status).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:delete_email_identity).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:verify_dkim).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:activate_dkim).and_return(double('status').as_null_object)
    allow_any_instance_of(EmailService::DomainVerificationsController).to receive(:deactivate_dkim).and_return(double('status').as_null_object)

  end

  # check index route
  describe "GET 'index'" do

    puts "\n ==============================================================\n"
    puts "\n [DomainVerificationsController][index] \n"
    puts "\n ==============================================================\n"

    # check email admin role
    context 'email_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << { 'id' => 'email_service_role', 'name' => 'email_admin' }
          token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          # puts "\n Token Inspect:  #{token.inspect} \n"
          token
        end
      end
      it 'returns http 200 status' do
        get :index, params: default_params
        expect(response).to render_template(:index)
        expect(response).to have_http_status(200)
        # puts "\n The response is #{response.inspect} \n"
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
      it 'returns http 200 status' do
        get :index, params: default_params
        expect(response).to render_template(:index)
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



  # check new route
  describe "GET 'new'" do

    puts "\n ==============================================================\n"
    puts "\n [DomainVerificationsController][new] \n"
    puts "\n ==============================================================\n"

    before :each do
      @rsa_key_length = ::EmailService::FakeFactory.new.rsa_key_length
      @configsets_collection = ::EmailService::FakeFactory.new.configsets_collection
      @verified_domain = ::EmailService::FakeFactory.new.verified_domain
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


  # check create route
  describe "POST 'create'" do

    puts "\n ==============================================================\n"
    puts "\n [DomainVerificationsController][create] \n"
    puts "\n ==============================================================\n"

    before :each do
      @verified_domain = ::EmailService::FakeFactory.new.verified_domain
      @verified_domain_opts = ::EmailService::FakeFactory.new.verified_domain_opts
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

      it 'returns http 302 status' do
        assigns(verified_domain: @verified_domain)
        assigns(verified_domain_opts: @verified_domain_opts)
        post(:create, params: default_params.merge(opts: @verified_domain_opts))
        expect(response).to have_http_status(302)
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
      it 'returns http 302 status' do
        assigns(verified_domain_opts: @verified_domain_opts)
        expect(post(:create, params: default_params.merge(verified_email: @verified_domain_opts))).to have_http_status(302)
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
        post :create, params: default_params
        expect(response).to render_template('application/exceptions/warning.html')
      end
    end

  end


  # check delete route
  describe "DELETE#destroy" do

    puts "\n ==============================================================\n"
    puts "\n [DomainVerificationsController][delete] \n"
    puts "\n ==============================================================\n"

    before :each do
      @opts = EmailService::FakeFactory.new.verified_domain_opts
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
        delete :destroy, params: default_params.merge(id: @opts[:id])
        expect(response).to render_template('application/exceptions/warning.html')
      end
    end

  end

  # check verify_dkim route
  describe "verify_dkim" do

    puts "\n ==============================================================\n"
    puts "\n [DomainVerificationsController][verify_dkim] \n"
    puts "\n ==============================================================\n"

    before :each do
      @opts = EmailService::FakeFactory.new.verified_domain_opts
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
        post :verify_dkim, params: default_params.merge(id: @opts[:id])
        expect(response).to render_template('application/exceptions/warning.html')
      end
    end

  end

  # check post#activate_dkim route
  describe "POST#activate_dkim" do

    puts "\n ==============================================================\n"
    puts "\n [DomainVerificationsController][activate_dkim] \n"
    puts "\n ==============================================================\n"

    before :each do
      @opts = EmailService::FakeFactory.new.verified_domain_opts
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
        post :activate_dkim, params: default_params.merge(id: @opts[:id])
        expect(response).to render_template('application/exceptions/warning.html')
      end
    end

  end

  # check post#deactivate_dkim route
  describe "POST#deactivate_dkim" do

    puts "\n ==============================================================\n"
    puts "\n [DomainVerificationsController][deactivate_dkim] \n"
    puts "\n ==============================================================\n"

    before :each do
      @opts = EmailService::FakeFactory.new.verified_domain_opts
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
        post :deactivate_dkim, params: default_params.merge(id: @opts[:id])
        expect(response).to render_template('application/exceptions/warning.html')
      end
    end

  end

end
