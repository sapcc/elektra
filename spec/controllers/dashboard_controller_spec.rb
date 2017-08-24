require 'spec_helper'

describe DashboardController, type: :controller do
  controller do
    def index
      head :ok
    end
  end

  default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}

  before(:all) do
    FriendlyIdEntry.find_or_create_entry('Domain', nil, default_params[:domain_id], 'default')
    FriendlyIdEntry.find_or_create_entry('Project', default_params[:domain_id], default_params[:project_id], default_params[:project_id])
  end

  before :each do
    stub_authentication
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, {domain_id: AuthenticationStub.domain_id}
      expect(response).to be_success
    end
  end

  describe 'can_access_scope?' do
    context 'project id is provided' do
      context 'and user has access to project' do
        before :each do
          project = double('Project', id: default_params[:project_id])
          allow(controller.service_user.identity).to receive(:user_projects).and_return([project])
        end

        it 'should return true' do
          get :index, default_params
          expect(controller.can_access_scope?).to eq(true)
        end
      end

      context 'user has no access to project' do
        before :each do
          project = double('Project', id: '123456')
          allow(controller.service_user.identity).to receive(:user_projects).and_return([project])
        end

        it 'should return true' do
          get :index, default_params
          expect(controller.can_access_scope?).to eq(false)
        end
      end
    end

    context 'project id is nil and domain id is provided' do
      context 'and user has access to domain' do
        before :each do
          allow(Rails.cache).to receive(:fetch)
            .with("user_role_assignments/#{AuthenticationStub.test_token['user']['id']}", anything)
            .and_return true
        end

        it 'should return true' do
          get :index, { domain_id: default_params[:domain_id] }
          expect(controller.can_access_scope?).to eq(true)
        end
      end
      context 'and user has no access to domain' do
        before :each do
          allow(Rails.cache).to receive(:fetch)
            .with("user_role_assignments/#{AuthenticationStub.test_token['user']['id']}", anything)
            .and_return false
        end

        it 'should return true' do
          get :index, { domain_id: default_params[:domain_id] }
          expect(controller.can_access_scope?).to eq(false)
        end
      end
    end
  end

end
