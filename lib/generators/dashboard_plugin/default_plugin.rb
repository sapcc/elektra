# frozen_string_literal: true

module DefaultPluginGenerator

  def generate_default_plugin
    create_service_layer_service
  end

  def update_assets
    remove_file "#{PLUGINS_PATH}/#{name}/app/assets/stylesheets/#{name}/application.css"
    remove_file "#{PLUGINS_PATH}/#{name}/app/assets/javascripts/#{name}/application.js"
    copy_file 'app/assets/_application.scss', "#{PLUGINS_PATH}/#{name}/app/assets/stylesheets/#{name}/_application.scss"
    copy_file 'app/assets/plugin.js', "#{PLUGINS_PATH}/#{name}/app/assets/javascripts/#{name}/plugin.js"
    gsub_file "#{PLUGINS_PATH}/#{name}/app/assets/javascripts/#{name}/plugin.js", '%{PLUGIN_NAME}', name
  end

  def modify_application_controller
    remove_file "#{PLUGINS_PATH}/#{name}/app/controllers/#{name}/application_controller.rb"
    copy_file 'app/controllers/application_controller.rb', "#{PLUGINS_PATH}/#{name}/app/controllers/#{name}/application_controller.rb"
    copy_file 'app/views/application/index.html.haml', "#{PLUGINS_PATH}/#{name}/app/views/#{name}/application/index.html.haml"
    gsub_file "#{PLUGINS_PATH}/#{name}/app/views/#{name}/application/index.html.haml", '%{PLUGIN_NAME}', name.camelize
    gsub_file "#{PLUGINS_PATH}/#{name}/app/controllers/#{name}/application_controller.rb", '%{PLUGIN_NAME}', name.camelize
  end

  def add_routes
    remove_file "#{PLUGINS_PATH}/#{name}/config/routes.rb"
    copy_file 'default/config/routes.rb', "#{PLUGINS_PATH}/#{name}/config/routes.rb"
    gsub_file "#{PLUGINS_PATH}/#{name}/config/routes.rb", '%{PLUGIN_NAME}', name.camelize
  end

end
