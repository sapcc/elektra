# Load spec files from plguins folder.
# consider only available plugins (ignore black listed in Gemfile)
Core::PluginsManager.available_plugins.each do |plugin|
  Dir[File.join(plugin.path, "spec/**/*_spec.rb")].each { |f| require f }
end
