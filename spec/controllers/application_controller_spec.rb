require 'spec_helper'

describe ApplicationController, type: :controller do
  
  controller do
    def index
      render html: '<h1>test</h1>'
    end
  end

  include AuthenticationStub

  before :each do
    stub_authentication

    admin_identity_driver = double('admin_identity_service_driver').as_null_object
    allow_any_instance_of(ServiceLayer::AdminIdentityService).to receive(:init) do |admin_identity|
      admin_identity.instance_variable_set(:@driver, admin_identity_driver)
    end

    allow(controller).to receive(:_routes).and_return(@routes)
  end

  context "non modal request" do

    describe "GET 'index'" do
      
      it "returns http success" do
        get :index
        expect(controller.modal?).to eq(false)
      end
    end
  end
  
  context "modal request" do

    describe "GET 'index'" do
      it "returns http success" do
        xhr :get, :index, modal: true
        expect(controller.modal?).to eq(true)
      end
    end
  end

end
