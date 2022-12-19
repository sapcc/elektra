require "spec_helper"

describe Core do
  let!(:auth_user) { double("current_user").as_null_object }

  before :each do
    # @current_user = double('current_user').as_null_object
    # allow(controller).to receive(:current_user).and_return(@current_user)
    allow(Core).to receive(:locate_region).and_call_original
  end

  describe "::locate_region" do
    context "default region is nil and default services region is nil" do
      before :each do
        allow(auth_user).to receive(:default_services_region).and_return(nil)
      end

      it "should return nil" do
        expect(Core.locate_region(auth_user, nil)).to be(nil)
      end
    end

    context "default region is nil and default services region exists" do
      before :each do
        allow(auth_user).to receive(:default_services_region).and_return(
          "europe",
        )
      end

      it "should return default services region" do
        expect(Core.locate_region(auth_user, nil)).to eq("europe")
      end
    end

    context "default region is a string and available regions contain default region" do
      before :each do
        allow(auth_user).to receive(:available_services_regions).and_return(
          %w[de us europe],
        )
      end

      it "should return default region" do
        expect(Core.locate_region(auth_user, "europe")).to eq("europe")
      end
    end

    context "default region is a string and available regions does not contain default region" do
      before :each do
        allow(auth_user).to receive(:available_services_regions).and_return(
          %w[de us es],
        )
        allow(auth_user).to receive(:default_services_region).and_return(
          auth_user.available_services_regions.first,
        )
      end

      it "should return default_services_region" do
        expect(Core.locate_region(auth_user, "europe")).to eq("de")
      end
    end

    context "default region is a string and current_user is nil" do
      it "should return default region" do
        expect(Core.locate_region(nil, "europe")).to eq("europe")
      end
    end

    context "default region is an array and available regions contain default regions" do
      before :each do
        allow(auth_user).to receive(:available_services_regions).and_return(
          %w[de us es europe],
        )
      end

      it "should return first of default regions" do
        expect(Core.locate_region(auth_user, %w[europe de])).to eq("europe")
      end
    end

    context "default region is an array and available regions contain default region" do
      before :each do
        allow(auth_user).to receive(:available_services_regions).and_return(
          %w[de us es],
        )
      end

      it "should return last of default regions" do
        expect(Core.locate_region(auth_user, %w[europe de])).to eq("de")
      end
    end

    context "default region is an array and available regions does not contain default regions" do
      before :each do
        allow(auth_user).to receive(:available_services_regions).and_return(
          %w[de us es],
        )
        allow(auth_user).to receive(:default_services_region).and_return(
          auth_user.available_services_regions.first,
        )
      end

      it "should return last of available regions" do
        expect(Core.locate_region(auth_user, %w[europe ru])).to eq("de")
      end
    end
  end
end
