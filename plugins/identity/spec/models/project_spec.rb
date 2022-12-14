require "spec_helper"

describe Identity::Project do
  before :each do
    @driver = double("driver").as_null_object
  end

  describe "friendly_id" do
    context "id is presented" do
      it "returns creates a new entry in identity_id_chaches" do
        project =
          Identity::Project.new(
            @driver,
            { "id" => 1, "name" => "project 1", "domain_id" => 1 },
          )
        expect { expect(project.friendly_id).to eq("project-1") }.to change {
          FriendlyIdEntry.count
        }.by(1)
      end

      it "returns only id if domain_id is nil" do
        project =
          Identity::Project.new(@driver, { "id" => 1, "name" => "project 1" })
        expect { expect(project.friendly_id).to eq(1) }.to change {
          FriendlyIdEntry.count
        }.by(0)
      end

      it "returns only id if name is nil" do
        project =
          Identity::Project.new(@driver, { "id" => 1, "domain_id" => 1 })
        expect { expect(project.friendly_id).to eq(1) }.to change {
          FriendlyIdEntry.count
        }.by(0)
      end
    end

    context "id is nil" do
      project = Identity::Project.new(@driver)

      it "returns nil" do
        expect(project.friendly_id).to eq(nil)
      end
    end
  end
end
