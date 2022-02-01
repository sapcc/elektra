require 'spec_helper'
require_relative '../factories/factories'

describe EmailService::EmailsController, type: :controller do
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
    allow_any_instance_of(EmailService::EmailsController).to receive(:list_verified_identities).and_return(double('identities').as_null_object)
    allow_any_instance_of(EmailService::EmailsController).to receive(:get_verified_identities_by_status).and_return(double('statuses').as_null_object)     
    allow_any_instance_of(EmailService::EmailsController).to receive(:get_send_stats).and_return(double('stats').as_null_object)           
    allow_any_instance_of(EmailService::EmailsController).to receive(:get_send_data).and_return(double('data').as_null_object)            
  end

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
      it 'returns http 200 status' do
        get :index, params: default_params
        expect(response).to have_http_status(200)
        expect(response).to render_template(:index)
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
        expect(response).to render_template(:index)
      end
    end
 
    context 'only cloud_support_tools_viewer_role' do
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

end
