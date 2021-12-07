
require 'spec_helper'

describe Galvani::TagsController, type: :controller do
  routes { Galvani::Engine.routes }

  default_params = {  domain_id: AuthenticationStub.domain_id,
                      project_id: AuthenticationStub.project_id}

  before(:all) do
    FriendlyIdEntry.find_or_create_entry(
      'Domain', nil, default_params[:domain_id], 'default'
    )
    FriendlyIdEntry.find_or_create_entry(
      'Project', default_params[:domain_id], default_params[:project_id],
      default_params[:project_id]
    )
  end

  describe "PUT 'create a tag'" do
    before :each do
      @existing_tag = "xs:internet:keppel_account_pull:d063222"
      allow(controller.cloud_admin).to receive(:list_tags).and_return([@existing_tag])
    end

    context 'validation' do
      it 'returns http success using profile and service with required variable' do
        post :create, params: default_params.merge({tag: "xs:internet:keppel_account_pull:cc-demo"})             
        expect(response).to be_successful
      end
      it 'returns http error using profile and service without required variable' do
        post :create, params: default_params.merge({tag: "xs:internet:keppel_account_pull"})
        expect(response).to_not be_successful
      end
      it 'returns http success using profile and service' do
        post :create, params: default_params.merge({tag: "xs:internet:dns:reader"})
        expect(response).to be_successful
      end
      it 'returns http error using profile and service and not required variable' do
        post :create, params: default_params.merge({tag: "xs:internet:dns:reader:test"})
        expect(response).to_not be_successful
      end
      it 'returns http error using just the profile name' do
        post :create, params: default_params.merge({tag: "xs:internet"})
        expect(response).to_not be_successful
      end
      it 'returns http error if tag already exists' do
        post :create, params: default_params.merge({tag: @existing_tag})
        expect(response).to_not be_successful
      end
    end
    
  end

end