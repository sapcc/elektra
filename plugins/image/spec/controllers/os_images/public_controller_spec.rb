require "spec_helper"

describe Image::OsImages::PublicController, type: :controller do
  routes { Image::Engine.routes }

  default_params = {
    domain_id: AuthenticationStub.domain_id,
    project_id: AuthenticationStub.project_id,
  }

  before(:all) do
    #DatabaseCleaner.clean
    FriendlyIdEntry.find_or_create_entry(
      "Domain",
      nil,
      default_params[:domain_id],
      "default",
    )
    FriendlyIdEntry.find_or_create_entry(
      "Project",
      default_params[:domain_id],
      default_params[:project_id],
      default_params[:project_id],
    )
  end

  before :each do
    stub_authentication

    os_image_service = double("image service").as_null_object
    allow_any_instance_of(ServiceLayer::ImageService).to receive(
      :elektron_images,
    ).and_return(os_image_service)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, params: default_params
      expect(response).to be_successful
    end
  end
end
