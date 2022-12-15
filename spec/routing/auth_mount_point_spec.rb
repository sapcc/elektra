require "spec_helper"

describe "auth mount point" do
  it "MonsoonOpenstackAuth::Engine mount point should start with domain_fid" do
    entry =
      Rails.application.routes.routes.entries.find do |e|
        e.app.try(:app) == MonsoonOpenstackAuth::Engine
      end
    expect(entry.required_parts.first).to eq(:domain_fid)
  end
end
