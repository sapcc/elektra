require "spec_helper"

describe ApplicationController, type: :controller do
  controller do
    def index
      render html: "<h1>test</h1>"
    end
  end

  before :each do
    stub_authentication
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
        get :index, params: { modal: true }, xhr: true
        expect(controller.modal?).to eq(true)
      end
    end
  end
end
