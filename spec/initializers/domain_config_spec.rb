require_relative '../../config/initializers/domain_config'

test_config = {
  "domains" => [
    {
      "name" => "all iaas",
      "regex" => "^iaas-.*$",
      "disabled_plugins" => ["plugin1", "plugin2"],
      "floating_ip_networks" => ["FloatingIP-external-%DOMAIN_NAME%-network"],
      "dns_c_subdomain" => true,
      "check_cidr_range" => true
    },
    {
      "name" => "test domain",
      "regex" => "^iaas-test1$",
      "disabled_plugins" => ["plugin3"],
      "dns_c_subdomain" => false,
      "check_cidr_range" => false
    }
  ]
}

describe DomainConfig do
  it "contains a class variable domain_config_file" do
    expect(DomainConfig.class_variable_get(:@@domain_config_file)).to be_a(Hash)
  end

  describe "test config" do 
    before :each do 
      DomainConfig.class_variable_set(:@@domain_config_file, test_config) 
    end

    describe "#initialize" do
      it "finds the correct domain config" do
        expect(DomainConfig.new("iaas-domain1").instance_variable_get(:@domain_config)).to eq(test_config["domains"][0])
      end

      # instead of taking the first matching config from the list, it should take the last one
      it "finds the last matching domain config" do
        expect(DomainConfig.new("iaas-test1").instance_variable_get(:@domain_config)).to eq(test_config["domains"][1])
      end
    end

    describe "#plugin_hidden?" do
      it "returns true if the plugin is disabled" do
        expect(DomainConfig.new("iaas-domain1").plugin_hidden?("plugin1")).to be true
      end

      it "returns false if the plugin is not disabled" do
        expect(DomainConfig.new("iaas-domain1").plugin_hidden?("plugin3")).to be false
      end
    end

    describe "#floating_ip_networks" do
      it "returns the floating ip networks" do
        expect(DomainConfig.new("iaas-domain1").floating_ip_networks).to eq([ "FloatingIP-external-iaas-domain1-network" ])
      end

      it "replaces %DOMAIN_NAME% with the scoped domain name" do
        expect(DomainConfig.new("iaas-domain1").floating_ip_networks).to eq([ "FloatingIP-external-iaas-domain1-network" ])
      end

      it "returns an empty array if no floating ip networks are configured" do
        expect(DomainConfig.new("iaas-test1").floating_ip_networks).to eq([])
      end
    end

    describe "#dns_sap_only?" do
      it "returns true if the domain is dns_sap_only" do
        expect(DomainConfig.new("iaas-domain1").dns_c_subdomain?).to be true
      end

      it "returns false if the domain is not dns_sap_only" do
        expect(DomainConfig.new("iaas-test1").dns_c_subdomain?).to be false
      end
    end

    describe "#check_cidr_range?" do
      it "returns true if the domain is check_cidr_range" do
        expect(DomainConfig.new("iaas-domain1").check_cidr_range?).to be true
      end

      it "returns false if the domain is not check_cidr_range" do
        expect(DomainConfig.new("iaas-test1").check_cidr_range?).to be false
      end
    end
  end
end
