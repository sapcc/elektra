require 'restclient'

# RestClient logs using << which isn't supported by the Rails logger,
# so wrap it up with a little proxy object.
RestClient.log =
  Object.new.tap do |proxy|
    def proxy.<<(message)
      Rails.logger.info message
    end
  end

# Read automation related configuration
AUTOMATION_CONF = YAML.load(ERB.new(File.read(File.join(Core::PluginsManager.plugin("automation").path, 'config/config.yml'))).result)[Rails.env]

# check env varibales

if (AUTOMATION_CONF['arc_latest_base_url'].nil? || AUTOMATION_CONF['arc_updates_url'].nil? ) || AUTOMATION_CONF['arc_pki_url'].nil? || AUTOMATION_CONF['arc_broker_url'].nil?
  puts
  puts "################ WARNING ################"
  puts "Automation ENV variables not set"
  puts "Env variable 'ARC_UPDATES_URL' not set." if AUTOMATION_CONF['arc_latest_base_url'].nil? || AUTOMATION_CONF['arc_updates_url'].nil?
  puts "Env variable 'ARC_PKI_URL' not set." if AUTOMATION_CONF['arc_pki_url'].nil?
  puts "Env variable 'ARC_BROKER_URL' not set." if AUTOMATION_CONF['arc_broker_url'].nil?
  puts "#########################################"
  puts
end