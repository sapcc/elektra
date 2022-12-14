require "spec_helper"

describe Identity::Domain do
  before :each do
    @driver = double("driver").as_null_object
  end

  describe "friendly_id" do
    context "id is presented" do
      it "returns creates a new entry in identity_id_chaches" do
        domain =
          Identity::Domain.new(@driver, { "id" => 1, "name" => "domain 1" })
        expect { expect(domain.friendly_id).to eq("domain-1") }.to change {
          FriendlyIdEntry.count
        }.by(1)
      end

      it "returns only id if name is nil" do
        domain = Identity::Domain.new(@driver, { "id" => 1 })
        expect { expect(domain.friendly_id).to eq(1) }.to change {
          FriendlyIdEntry.count
        }.by(0)
      end
    end

    context "id is nil" do
      domain = Identity::Domain.new(@driver)

      it "returns nil" do
        expect(domain.friendly_id).to eq(nil)
      end
    end
  end
end
