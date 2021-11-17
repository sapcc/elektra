require 'spec_helper'

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
 
  # check index route
  describe "GET 'index'" do
    before :each do
      allow_any_instance_of(EmailService::EmailsController).to receive(:list_verified_identities).and_return(double('identities').as_null_object)
      allow_any_instance_of(EmailService::EmailsController).to receive(:get_verified_identities_by_status).and_return(double('statuses').as_null_object)     
      allow_any_instance_of(EmailService::EmailsController).to receive(:get_send_stats).and_return(double('stats').as_null_object)           
      allow_any_instance_of(EmailService::EmailsController).to receive(:get_send_data).and_return(double('data').as_null_object)            
      allow_any_instance_of(EmailService::EmailsController).to receive(:get_ec2_creds).and_return(double('creds').as_null_object)
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
 
  end

  # check info route
    describe "GET 'info'" do
      before :each do
        allow_any_instance_of(EmailService::EmailsController).to receive(:list_verified_identities).and_return(double('identities').as_null_object)
        allow_any_instance_of(EmailService::EmailsController).to receive(:get_verified_identities_by_status).and_return(double('statuses').as_null_object)     
        allow_any_instance_of(EmailService::EmailsController).to receive(:get_verified_identities_collection).and_return(double('identities_collection').as_null_object)
        allow_any_instance_of(EmailService::EmailsController).to receive(:get_send_stats).and_return(double('stats').as_null_object)           
        allow_any_instance_of(EmailService::EmailsController).to receive(:get_send_data).and_return(double('data').as_null_object)            
        allow_any_instance_of(EmailService::EmailsController).to receive(:get_ec2_creds).and_return(double('creds').as_null_object)
        allow_any_instance_of(EmailService::EmailsController).to receive(:get_all_templates).and_return(double('templates').as_null_object)    
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
   
    end

end

# RSpec.describe "load plain_email_form", :type => :request do
#   it 'creates a new plain email form' do
#     get "/new"
#     expect(response).to render_template(:new)
#   end
# end