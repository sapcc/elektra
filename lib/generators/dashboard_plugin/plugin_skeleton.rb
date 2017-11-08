# frozen_string_literal: true

module PluginSkeletonGenerator
  def generate_plugin_skeleton
    plugin_options = '--skip-gemfile --skip-bundle --skip-git --skip-test'
    plugin_options += ' --mountable' if options.mountable?
    plugin_options += ' --full' if options.service_layer? && !options.mountable?

    generate(:plugin, "#{self.class::PLUGINS_PATH}/#{name}", plugin_options)

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

  def create_service_layer_service
    copy_file 'app/services/service_layer_ng/service.rb', "#{PLUGINS_PATH}/#{name}/app/services/service_layer_ng/#{name}_service.rb"
    gsub_file "#{PLUGINS_PATH}/#{name}/app/services/service_layer_ng/#{name}_service.rb", '%{PLUGIN_NAME}', name.camelize
  end

  def update_dependencies_to_gemspec
    remove_file "#{PLUGINS_PATH}/#{name}/lib/#{name}/version.rb"
    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", "#{name.camelize}::VERSION", '"0.0.1"'
    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", "# Maintain your gem's version:\n", ''
    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", "require \"#{name}/version\"", ''
    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", /TODO:?/, ''

    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", /s.add_dependency "rails"[^\n]*\n/, ''
    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", /s.add_development_dependency "sqlite3"/, ''
  end

  def replace_test_with_spec
    remove_dir "#{PLUGINS_PATH}/#{name}/test"
    create_file "#{PLUGINS_PATH}/#{name}/spec/.keep"
  end

  def add_controller_spec
    copy_file 'spec/controllers/application_controller_spec.rb', "#{PLUGINS_PATH}/#{name}/spec/controllers/application_controller_spec.rb"
    gsub_file "#{PLUGINS_PATH}/#{name}/spec/controllers/application_controller_spec.rb", '%{PLUGIN_NAME}', name.camelize

    gsub_file "#{PLUGINS_PATH}/#{name}/spec/controllers/application_controller_spec.rb", '%{PLUGIN_NAME}', name.camelize
  end
end
