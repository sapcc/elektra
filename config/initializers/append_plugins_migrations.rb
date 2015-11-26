# add plugins migration paths to main app's db migrations
PluginsManager.available_plugins.each do |plugin|
  Rails.application.config.paths["db/migrate"].push(plugin.path+"/db/migrate")
end
