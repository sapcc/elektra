# frozen_string_literal: true

class DashboardPluginGenerator < Rails::Generators::NamedBase
  PLUGINS_PATH = 'plugins'

  source_root File.expand_path('../templates', __FILE__)
  class_option :mountable, type: :boolean, default: false, description: 'Generate mountable isolated application'
  class_option :service_layer, type: :boolean, default: false, description: 'Generate service layer (app/services/service_layer/)'
  class_option :react, type: :boolean, default: false, description: 'Generate plugin using react/redux js-lib'

  def generate_plugin_skeleton
    plugin_options = '--skip-gemfile --skip-bundle --skip-git --skip-test-unit'
    plugin_options += ' --mountable' if options.mountable?
    plugin_options += ' --full' if options.service_layer? and !options.mountable?

    generate(:plugin, "#{PLUGINS_PATH}/#{name}", plugin_options)
  end

  def adapt_plugin
    replace_test_with_spec
    update_dependencies_to_gemspec

    update_assets

    if options.mountable?
      modify_application_controller
      add_routes
      add_controller_spec
    end

    if options.service_layer?
      create_service_layer_service
    end
  end

  private

  def update_dependencies_to_gemspec
    remove_file "#{PLUGINS_PATH}/#{name}/lib/#{name}/version.rb"
    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", "#{name.camelize}::VERSION", '"0.0.1"'
    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", "# Maintain your gem's version:\n", ''
    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", "require \"#{name}/version\"", ''
    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", /TODO:?/, ''

    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", /s.add_dependency "rails"[^\n]*\n/, ''
    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", /s.add_development_dependency "sqlite3"/, ''
  end

  def create_service_layer_service
    copy_file "app/services/service_layer_ng/service.rb", "#{PLUGINS_PATH}/#{name}/app/services/service_layer_ng/#{name}_service.rb"
    gsub_file "#{PLUGINS_PATH}/#{name}/app/services/service_layer_ng/#{name}_service.rb", '%{PLUGIN_NAME}', name.camelize
  end

  def update_assets
    remove_file "#{PLUGINS_PATH}/#{name}/app/assets/stylesheets/#{name}/application.css"
    remove_file "#{PLUGINS_PATH}/#{name}/app/assets/javascripts/#{name}/application.js"

    copy_file "app/assets/_application.scss", "#{PLUGINS_PATH}/#{name}/app/assets/stylesheets/#{name}/_application.scss"

    if options.react?
      directory 'react_app/javascript', "#{PLUGINS_PATH}/#{name}/app/javascript"

      Dir.glob("#{PLUGINS_PATH}/#{name}/app/javascript/**/*").each do |file|
        gsub_file(file, '%{PLUGIN_NAME}', name) if File.file?(file)
      end
    else
      copy_file "app/assets/plugin.js", "#{PLUGINS_PATH}/#{name}/app/assets/javascripts/#{name}/plugin.js"
      gsub_file "#{PLUGINS_PATH}/#{name}/app/assets/javascripts/#{name}/plugin.js", '%{PLUGIN_NAME}', name
    end
  end

  def modify_application_controller
    remove_file "#{PLUGINS_PATH}/#{name}/app/controllers/#{name}/application_controller.rb"

    if options.react?
      copy_file "react_app/controllers/application_controller.rb", "#{PLUGINS_PATH}/#{name}/app/controllers/#{name}/application_controller.rb"
      remove_dir "#{PLUGINS_PATH}/#{name}/app/views"
    else
      copy_file "app/controllers/application_controller.rb", "#{PLUGINS_PATH}/#{name}/app/controllers/#{name}/application_controller.rb"
      copy_file "app/views/application/index.html.haml", "#{PLUGINS_PATH}/#{name}/app/views/#{name}/application/index.html.haml"
      gsub_file "#{PLUGINS_PATH}/#{name}/app/views/#{name}/application/index.html.haml", '%{PLUGIN_NAME}', name.camelize
    end

    gsub_file "#{PLUGINS_PATH}/#{name}/app/controllers/#{name}/application_controller.rb", '%{PLUGIN_NAME}', name.camelize
  end

  def replace_test_with_spec
    create_file "#{PLUGINS_PATH}/#{name}/spec/.keep"
  end

  def add_controller_spec
    copy_file 'spec/controllers/application_controller_spec.rb', "#{PLUGINS_PATH}/#{name}/spec/controllers/application_controller_spec.rb"
    gsub_file "#{PLUGINS_PATH}/#{name}/spec/controllers/application_controller_spec.rb", '%{PLUGIN_NAME}', name.camelize

    gsub_file "#{PLUGINS_PATH}/#{name}/spec/controllers/application_controller_spec.rb", '%{PLUGIN_NAME}', name.camelize
  end

  def add_routes
    remove_file "#{PLUGINS_PATH}/#{name}/config/routes.rb"
    if options.react?
      copy_file 'react_app/config/routes.rb', "#{PLUGINS_PATH}/#{name}/config/routes.rb"
    else
      copy_file 'config/routes.rb', "#{PLUGINS_PATH}/#{name}/config/routes.rb"
    end
    gsub_file "#{PLUGINS_PATH}/#{name}/config/routes.rb", '%{PLUGIN_NAME}', name.camelize
  end

end
