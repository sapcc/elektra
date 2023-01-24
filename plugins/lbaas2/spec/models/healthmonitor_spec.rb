require "spec_helper"

module Lbaas2
  class FakeFactory
    def healthmonitor(params = {})
      ::Lbaas2::Healthmonitor.new(
        {
          name: "healthmonitor_test",
          type: "HTTP",
          delay: "10",
        }.merge(params),
      )
    end
  end
end

describe ::Lbaas2::Healthmonitor do
  describe "max_retries" do
    it "attributes_for_createmax_retries default to 1" do
      healthmonitor = Lbaas2::FakeFactory.new.healthmonitor()
      expect(healthmonitor.attributes_for_create["max_retries"]).to match(
        1
      )
    end
    it "attributes_for_update max_retries default to 1" do
      healthmonitor = Lbaas2::FakeFactory.new.healthmonitor()
      expect(healthmonitor.attributes_for_update["max_retries"]).to match(
        1
      )
    end
  end
  describe "timeout" do
    it "attributes_for_createmax_retries default to 1" do
      healthmonitor = Lbaas2::FakeFactory.new.healthmonitor()
      expect(healthmonitor.attributes_for_create["timeout"]).to match(
        0
      )
    end
    it "attributes_for_update max_retries default to 1" do
      healthmonitor = Lbaas2::FakeFactory.new.healthmonitor()
      expect(healthmonitor.attributes_for_update["timeout"]).to match(
        0
      )
    end
  end
end