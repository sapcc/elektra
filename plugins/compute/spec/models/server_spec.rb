# frozen_string_literal: true
require "spec_helper"

describe Compute::Server do
  let(:server) do
    Compute::Server.new(
      nil,
      addresses: {
        "Network 1" => [
          {
            "OS-EXT-IPS-MAC:mac_addr" => "fa:16:3e:c0:7a:2b",
            "version" => 4,
            "addr" => "10.180.0.33",
            "OS-EXT-IPS:type" => "fixed",
          },
          {
            "OS-EXT-IPS-MAC:mac_addr" => "fa:16:3e:a5:e4:b4",
            "version" => 4,
            "addr" => "10.180.0.60",
            "OS-EXT-IPS:type" => "fixed",
          },
          {
            "OS-EXT-IPS-MAC:mac_addr" => "fa:16:3e:c0:7a:2b",
            "version" => 4,
            "addr" => "10.44.32.21",
            "OS-EXT-IPS:type" => "floating",
          },
        ],
        "Network 2" => [
          {
            "OS-EXT-IPS-MAC:mac_addr" => "fa:16:3e:df:c0:83",
            "version" => 4,
            "addr" => "10.180.0.17",
            "OS-EXT-IPS:type" => "fixed",
          },
        ],
      },
    )
  end

  project_floating_ips = [
    Networking::FloatingIp.new(
      nil,
      {
        id: "1",
        floating_ip_address: "10.44.32.21",
        fixed_ip_address: "10.180.0.33",
      },
    ),
  ]

  describe "#ip_maps" do
    let(:ips) { server.ip_maps(project_floating_ips) }

    it "responds to ip_maps" do
      expect(server).to respond_to(:ip_maps)
    end

    it "returns an array" do
      expect(ips.is_a?(Array)).to eq(true)
    end

    it "returns an array with 3 entries" do
      expect(ips.length).to eq(3)
    end

    it "should contains two different networks" do
      networks = ips.collect { |ip| ip["fixed"]["network_name"] }.uniq.sort
      expect(networks).to eq(["Network 1", "Network 2"])
    end

    it "should contain two entries with network Network 1" do
      network1_ips =
        ips.select { |ip| ip["fixed"]["network_name"] == "Network 1" }
      expect(network1_ips.length).to eq(2)
    end

    it "should contain two entries with network Network 2" do
      network2_ips =
        ips.select { |ip| ip["fixed"]["network_name"] == "Network 2" }
      expect(network2_ips.length).to eq(1)
    end

    context "Floating IP is assigned" do
      let(:assigned_ip) do
        ips.find { |ip| ip["fixed"]["addr"] == "10.180.0.33" }
      end

      it "contains fixed and floating keys" do
        expect(assigned_ip.keys.sort).to eq(%w[fixed floating])
      end

      it "should map fixed to floating ips" do
        expect(assigned_ip["floating"]["addr"]).to eq("10.44.32.21")
      end
    end

    context "Floating IP is not assigned" do
      let(:unassigned_ip) do
        ips.find { |ip| ip["fixed"]["addr"] == "10.180.0.60" }
      end

      it "should contain only fixed IP" do
        expect(unassigned_ip.keys).to eq(%w[fixed])
      end
    end
  end
end
