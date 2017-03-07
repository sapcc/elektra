require 'spec_helper'

describe Identity::ProjectsController, type: :controller do
  routes { Identity::Engine.routes }



  default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}

  before(:all) do
    #DatabaseCleaner.clean
    @domain_friendly_id_entry = FriendlyIdEntry.find_or_create_entry('Domain',nil,default_params[:domain_id],'default')
    @project_friendly_id_entry = FriendlyIdEntry.find_or_create_entry('Project',default_params[:domain_id],default_params[:project_id],default_params[:project_id])
  end

  before :each do
    stub_authentication
    stub_admin_services

    identity_driver = double('identity_service_driver').as_null_object
    allow_any_instance_of(ServiceLayer::IdentityService).to receive(:driver).and_return(identity_driver)

    allow(UserProfile).to receive(:tou_accepted?).and_return true
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :user_projects, default_params
      expect(response).to be_success
    end
  end

  context "unfinshed wizard state" do
    before :each do
      ProjectProfile.destroy_all(project_id: default_params[:project_id])
    end
    describe "GET show" do
      subject { get :show, default_params }

      # TODO: activate this test after some manual tests in staging
      # it "should redirect to the wizard page" do
      #   expect(subject).to redirect_to(action: :show_wizard, domain_id: default_params[:domain_id], project_id: default_params[:project_id])
      # end
    end
  end

  context "wizard finished" do
    before :each do
      profile = ProjectProfile.find_or_create_by_project_id(default_params[:project_id])
      profile.update_wizard_status('cost_control',ProjectProfile::STATUS_DONE)
      profile.update_wizard_status('resource_management',ProjectProfile::STATUS_DONE)
      profile.update_wizard_status('networking',ProjectProfile::STATUS_DONE)
    end

    describe "GET show" do
      subject { get :show, default_params }

      it "should redirect to the wizard page" do
        expect(subject).to render_template(:show)
      end
    end
  end

end
