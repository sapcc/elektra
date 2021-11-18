# require 'spec_helper'

# describe EmailService::TemplatedEmailsController, type: :controller do
#   routes { EmailService::Engine.routes }
 
#   default_params = { domain_id: AuthenticationStub.domain_id,
#                      project_id: AuthenticationStub.project_id }
 
#   before(:all) do
#     FriendlyIdEntry.find_or_create_entry(
#       'Domain', nil, default_params[:domain_id], 'default'
#     )
#     FriendlyIdEntry.find_or_create_entry(
#       'Project', default_params[:domain_id], default_params[:project_id],
#       default_params[:project_id]
#     )

#   end


  # # check new route
  # describe "GET 'new'" do
  #   before :each do
  #     allow_any_instance_of(EmailService::TemplatedEmailsController).to receive(:list_verified_identities).and_return(double('verified_identities').as_null_object)            
  #     allow_any_instance_of(EmailService::TemplatedEmailsController).to receive(:get_verified_identities_by_status).and_return(double('verified_identities_by_status').as_null_object)
  #     allow_any_instance_of(EmailService::TemplatedEmailsController).to receive(:get_configset).and_return(double('config_sets').as_null_object)            
  #     allow_any_instance_of(EmailService::TemplatedEmailsController).to receive(:get_ec2_creds).and_return(double('creds').as_null_object)
  # end
 
  #   # check email admin role
  #   context 'email_admin' do
  #     before :each do
  #       stub_authentication do |token|
  #         token['roles'] = []
  #         token['roles'] << { 'id' => 'email_service_role', 'name' => 'email_admin' }
  #         token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }         
  #         token
  #       end
  #     end
  #     it 'returns http success' do
  #       get :new, params: default_params
  #       # let(:region) = "eu-central-1"
  #       expect(response).to be_successful
  #     end
  #   end

  #   # check email user role
  #   context 'email_user' do
  #     before :each do
  #       stub_authentication do |token|
  #         token['roles'] = []
  #         token['roles'] << { 'id' => 'email_service_role', 'name' => 'email_user' }
  #         token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }         
  #         token
  #       end
  #     end
  #     it 'returns http success' do
  #       get :new, params: default_params
  #       expect(response).to be_successful
  #     end
  #   end
 
  #   # check without cloud_support_tools_viewer_role role
  #   context 'with cloud_support_tools_viewer_role' do
  #     before :each do
  #       stub_authentication do |token|
  #         token['roles'] = []
  #         token['roles'] << { 'id' => 'cloud_support_tools_viewer_role', 'name' => 'cloud_support_tools_viewer' }         
  #         token
  #       end
  #     end
  #     it 'returns http status' do
  #       get :new, params: default_params
  #       expect(response).to have_http_status(:ok)
  #     end
  #   end

#   end

# end
