require 'spec_helper'
require_relative '../factories/factories'

describe EmailService::EmailsController, type: :controller do
  routes { EmailService::Engine.routes }

  default_params = {
    domain_id: AuthenticationStub.domain_id,
    project_id: AuthenticationStub.project_id
  }

  before(:all) do
    FriendlyIdEntry.find_or_create_entry(
      'Domain', nil, default_params[:domain_id], 'default'
    )
    FriendlyIdEntry.find_or_create_entry(
      'Project', default_params[:domain_id],
      default_params[:project_id], default_params[:project_id]
    )
  end

  before :each do
    stub_authentication

    # email_service = double('email_service').as_null_object
    # allow_any_instance_of(ServiceLayer::EmailServiceService).to receive(
    #   :elektron_email_service
    # ).and_return(email_service)
    # allow(UserProfile).to receive(:tou_accepted?).and_return(true)
  end


  describe "GET 'index'" do
    it 'returns http success and renders the right template' do
      get :index, params: default_params
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end

end

