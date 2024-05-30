require_relative '../../config/initializers/domain_config'

test_config = {
  "domains" => [
    {
      "name" => "all iaas",
      "regex" => "^iaas-.*$",
      "disabled_plugins" => ["plugin1", "plugin2"]
    },
    {
      "name" => "test domain",
      "regex" => "^iaas-test1$",
      "disabled_plugins" => ["plugin3"]
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
  end
end
