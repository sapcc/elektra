require "yaml"

class BedrockConfig
  def initialize(scoped_domain_name)
    domains_config = YAML.load_file("#{Rails.root}/config/support/bedrock.yaml") || {}
    @domain_config = find_config(domains_config, scoped_domain_name)
  end

  def plugin_hidden?(name)
    return @domain_config.fetch("disabled_plugins", []).include?(name.to_s)
  end

  private

  def find_config(domains_config, scoped_domain_name)
    domains_config.fetch("domains", []).find do |domain_config|
      regex_pattern = Regexp.new(domain_config.fetch('regex', ''))
      scoped_domain_name =~ regex_pattern
    end || {}
  end
end
