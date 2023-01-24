require "spec_helper"

describe ::Lbaas2::Healthmonitor do
  describe "max_retries" do
    it "attributes_for_create max_retries default to 1" do
      healthmonitor = ::Lbaas2::Healthmonitor.new({max_retries: 5})
      expect(healthmonitor.attributes_for_create["max_retries"]).to match(
        1
      )
    end
    it "attributes_for_update max_retries default to 1" do
      healthmonitor = ::Lbaas2::Healthmonitor.new({max_retries: 5})
      expect(healthmonitor.attributes_for_update["max_retries"]).to match(
        1
      )
    end
  end
  describe "timeout" do
    it "attributes_for_create timeout default to 0" do
      healthmonitor = ::Lbaas2::Healthmonitor.new({timeout: 5})
      expect(healthmonitor.attributes_for_create["timeout"]).to match(
        0
      )
    end
    it "attributes_for_update timeout default to 0" do
      healthmonitor = ::Lbaas2::Healthmonitor.new({timeout: 5})
      expect(healthmonitor.attributes_for_update["timeout"]).to match(
        0
      )
    end
  end
end