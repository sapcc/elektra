require 'spec_helper'
require_relative '../factories/factories'

describe EmailService::SettingsController, type: :controller do
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

    Rails.logger.debug "\n ==============================================================\n"
    Rails.logger.debug "\n [SettingsController] \n"
    Rails.logger.debug "\n ==============================================================\n"

  end

  before :each do
    allow(UserProfile).to receive(:tou_accepted?).and_return(true)
    allow_any_instance_of(EmailService::SettingsController).to receive(:ec2_creds).and_return(double('creds').as_null_object)
    allow_any_instance_of(EmailService::SettingsController).to receive(:ses_client_v2).and_return(double('ses_client_v2').as_null_object)
    allow_any_instance_of(EmailService::SettingsController).to receive(:ses_client).and_return(double('ses_client').as_null_object)
    allow_any_instance_of(EmailService::SettingsController).to receive(:check_verified_identity).and_return(double('render').as_null_object)
    allow_any_instance_of(EmailService::SettingsController).to receive(:get_configset).and_return(double('configset').as_null_object)
    allow_any_instance_of(EmailService::SettingsController).to receive(:check_ec2_creds_cronus_status).and_return(double('redirect_path').as_null_object)
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

    # check without cloud_support_tools_viewer_role role
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
        expect(response).to render_template('application/exceptions/warning.html')
      end
    end

  end

end
