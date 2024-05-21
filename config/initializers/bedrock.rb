require "yaml"

# there are unit tests for this file. Have a look at elektra/spec/initializers/bedrock_spec.rb

class BedrockConfig
  # the order of the domains is important, the last matching domain will be used
  # we use a class variable to load the config only once
  # and make it possible to override the config in the tests
  @@bedrock_config_file = YAML.load_file("#{File.dirname(__FILE__)}/../support/bedrock.yaml") || {}

  def initialize(scoped_domain_name)
    # initialize the domain config using the find_config method
    @domain_config = find_config(@@bedrock_config_file, scoped_domain_name)
  end

  # returns true or false if plugin with name is hidden
  # this method allows to hide plugins for specific domains
  # it is used for building the services menu (config/navigation/*)
  def plugin_hidden?(name)
    return @domain_config.fetch("disabled_plugins", []).include?(name.to_s)
  end

  private

  def find_config(domains_config, scoped_domain_name)
    # to allow to match the last matching domain config, we reverse the list
    # it allows us to define a config matching all domains at the top and then 
    # override it with a more specific config.
    domains_config.fetch("domains", []).reverse.find do |domain_config|
      regex_pattern = Regexp.new(domain_config.fetch('regex', ''))
      scoped_domain_name =~ regex_pattern
    end || {}
  end
end
