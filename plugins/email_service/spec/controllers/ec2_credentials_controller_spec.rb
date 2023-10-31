require 'spec_helper'
require_relative '../factories/factories'

describe EmailService::Ec2CredentialsController, type: :controller do
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
      EmailService::Ec2CredentialsController
    ).to receive(:check_pre_conditions_for_cronus).and_return(
      double('redirect_path').as_null_object
    )
    allow_any_instance_of(
      EmailService::Ec2CredentialsController
    ).to receive(:create_credentials).and_return(
      double('credentials').as_null_object
    )
    allow_any_instance_of(
      EmailService::Ec2CredentialsController
    ).to receive(:find_credentials).and_return(
      double('credentials').as_null_object
    )
    allow_any_instance_of(
      EmailService::Ec2CredentialsController
    ).to receive(:delete_credentials).and_return(
      double('credentials').as_null_object
    )
    allow_any_instance_of(
      EmailService::Ec2CredentialsController
    ).to receive(:ec2_creds).and_return(double('creds').as_null_object)
    allow_any_instance_of(
      EmailService::Ec2CredentialsController
    ).to receive(:ses_client_v2).and_return(
      double('ses_client_v2').as_null_object
    )
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
          token
        end
      end
      it 'returns http success' do
        get :index, params: default_params
        expect(response).to be_successful
      end
    end

    context 'cloud_email_admin' do
      before :each do
        stub_authentication do |token|
          token['roles'] = []
          token['roles'] << {
            'id' => 'email_service_role',
            'name' => 'cloud_email_admin'
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
end
