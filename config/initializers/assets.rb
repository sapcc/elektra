# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
#Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w[automation/ansi_up.js]

Core::PluginsManager.plugins_with_plugin_js.each do |plugin|
  Rails.application.config.assets.precompile += ["#{plugin.name}/#{plugin.class::PLUGIN_JS_FILE_NAME}.js"]
end
