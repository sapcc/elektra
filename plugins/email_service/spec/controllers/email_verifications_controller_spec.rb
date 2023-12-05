require 'spec_helper'
require_relative '../factories/factories'

describe EmailService::EmailVerificationsController, type: :controller do
  routes { EmailService::Engine.routes }

  default_params = {
    domain_id: AuthenticationStub.domain_id,
    project_id: AuthenticationStub.project_id
  }

  before(:all) do
    FriendlyIdEntry.find_or_create_entry(
      'Domain',
      nil,
      default_params[:domain_id],
      'default'
    )
    FriendlyIdEntry.find_or_create_entry(
      'Project',
      default_params[:domain_id],
      default_params[:project_id],
      default_params[:project_id]
    )
  end

  before :each do
    allow(UserProfile).to receive(:tou_accepted?).and_return(true)
    allow_any_instance_of(
      EmailService::EmailVerificationsController
    ).to receive(:check_pre_conditions_for_cronus).and_return(
      double('redirect_path').as_null_object
    )
    allow_any_instance_of(
      EmailService::EmailVerificationsController
    ).to receive(:email_addresses).and_return(
      double('email_addresses').as_null_object
    )
    allow_any_instance_of(
      EmailService::EmailVerificationsController
    ).to receive(:check_verified_identity).and_return(
      double('render').as_null_object
    )
    allow_any_instance_of(
      EmailService::EmailVerificationsController
    ).to receive(:ec2_creds).and_return(double('creds').as_null_object)
    allow_any_instance_of(
      EmailService::EmailVerificationsController
    ).to receive(:ses_client_v2).and_return(
      double('ses_client_v2').as_null_object
    )
    allow_any_instance_of(
      EmailService::EmailVerificationsController
    ).to receive(:list_configset_names).and_return(
      double('configsets_collection').as_null_object
    )
    allow_any_instance_of(
      EmailService::EmailVerificationsController
    ).to receive(:list_verified_identities).and_return(
      double('identities').as_null_object
    )
    allow_any_instance_of(
      EmailService::EmailVerificationsController
    ).to receive(:get_verified_identities_by_status).and_return(
      double('status').as_null_object
    )
    allow_any_instance_of(
      EmailService::EmailVerificationsController
    ).to receive(:delete_email_identity).and_return(
      double('status').as_null_object
    )
    allow_any_instance_of(
      EmailService::EmailVerificationsController
    ).to receive(:verify_identity).and_return(double('status').as_null_object)
  end

  # check index route
  describe 'GET index' do
    context 'email_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << {
            'id' => 'email_service_role',
            'name' => 'email_admin'
          }
          token['roles'] << {
            'id' => 'cloud_support_tools_viewer_role',
            'name' => 'cloud_support_tools_viewer'
          }
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
          token['roles'] << {
            'id' => 'email_service_role',
            'name' => 'email_user'
          }
          token['roles'] << {
            'id' => 'cloud_support_tools_viewer_role',
            'name' => 'cloud_support_tools_viewer'
          }
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
          token['roles'] << {
            'id' => 'cloud_support_tools_viewer_role',
            'name' => 'cloud_support_tools_viewer'
          }
          token
        end
      end
      it 'returns http 401 status' do
        get :index, params: default_params
        expect(response).to render_template(
          'application/exceptions/warning'
        )
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
        expect(response).to render_template(
          'application/exceptions/warning'
        )
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
          token['roles'] << {
            'id' => 'email_service_role',
            'name' => 'email_admin'
          }
          # token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http success' do
        get :new, params: default_params
        # expect(response).to be_successful
        expect(response).to render_template(:new)
      end
    end

    # check email user role
    context 'email_user' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << {
            'id' => 'email_service_role',
            'name' => 'email_user'
          }
          # token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }
          token
        end
      end
      it 'returns http success' do
        get :new, params: default_params
        # expect(response).to be_successful
        expect(response).to render_template(:new)
      end
    end

    context 'cloud_support_tools_viewer_role alone' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << {
            'id' => 'cloud_support_tools_viewer_role',
            'name' => 'cloud_support_tools_viewer'
          }
          token
        end
      end
      it 'returns http 401 status' do
        get :new, params: default_params
        expect(response).to render_template(
          'application/exceptions/warning'
        )
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
        expect(response).to render_template(
          'application/exceptions/warning'
        )
      end
    end
  end

  # check create route
  describe "POST 'create'" do
    before :each do
      @opts = EmailService::FakeFactory.new.verified_email_opts
    end

    # check email admin role
    context 'email_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << {
            'id' => 'email_service_role',
            'name' => 'email_admin'
          }
          token['roles'] << {
            'id' => 'cloud_support_tools_viewer_role',
            'name' => 'cloud_support_tools_viewer'
          }
          token
        end
      end
      it 'returns http success' do
        # expect(post(:create, params: default_params.merge(verified_email: @opts))).to have_http_status(302)
        expect(
          post(:create, params: default_params.merge(verified_email: @opts))
        ).to have_http_status(200)
      end
    end

    # check email user role
    context 'email_user' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << {
            'id' => 'email_service_role',
            'name' => 'email_user'
          }
          token['roles'] << {
            'id' => 'cloud_support_tools_viewer_role',
            'name' => 'cloud_support_tools_viewer'
          }
          token
        end
      end
      it 'returns http success' do
        # expect(post(:create, params: default_params.merge(verified_email: @opts))).to have_http_status(302)
        expect(
          post(:create, params: default_params.merge(verified_email: @opts))
        ).to have_http_status(200)
      end
    end

    context 'cloud_support_tools_viewer_role alone' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << {
            'id' => 'cloud_support_tools_viewer_role',
            'name' => 'cloud_support_tools_viewer'
          }
          token
        end
      end
      it 'returns http 401 status' do
        expect(
          post(:create, params: default_params.merge(verified_email: @opts))
        ).to render_template('application/exceptions/warning')
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
        expect(
          post(:create, params: default_params.merge(verified_email: @opts))
        ).to render_template('application/exceptions/warning')
      end
    end
  end

  # check create route
  describe 'DELETE#destroy' do
    before :each do
      @opts = EmailService::FakeFactory.new.verified_email_opts
    end
    # check email admin role
    context 'email_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << {
            'id' => 'email_service_role',
            'name' => 'email_admin'
          }
          token['roles'] << {
            'id' => 'cloud_support_tools_viewer_role',
            'name' => 'cloud_support_tools_viewer'
          }
          token
        end
      end
      it 'returns http redirect' do
        expect(
          delete(:destroy, params: default_params.merge(id: @opts[:id]))
        ).to have_http_status(302)
      end
    end

    # check email user role
    context 'email_user' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << {
            'id' => 'email_service_role',
            'name' => 'email_user'
          }
          token['roles'] << {
            'id' => 'cloud_support_tools_viewer_role',
            'name' => 'cloud_support_tools_viewer'
          }
          token
        end
      end
      it 'returns http redirect' do
        expect(
          delete(:destroy, params: default_params.merge(id: @opts[:id]))
        ).to have_http_status(302)
      end
    end

    context 'cloud_support_tools_viewer_role alone' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << {
            'id' => 'cloud_support_tools_viewer_role',
            'name' => 'cloud_support_tools_viewer'
          }
          token
        end
      end
      it 'returns http 401 status' do
        expect(
          delete(:destroy, params: default_params.merge(id: @opts[:id]))
        ).to render_template('application/exceptions/warning')
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
        expect(
          delete(:destroy, params: default_params.merge(id: @opts[:id]))
        ).to render_template('application/exceptions/warning')
      end
    end
  end
end
