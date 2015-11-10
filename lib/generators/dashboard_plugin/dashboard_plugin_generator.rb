class DashboardPluginGenerator < Rails::Generators::NamedBase
  PLUGINS_PATH = 'plugins'

  source_root File.expand_path('../templates', __FILE__)  
  class_option :mountable, type: :boolean, default: false, description: "Generate mountable isolated application"
  class_option :service_layer, type: :boolean, default: false, description: "Generate service layer (app/services/service_layer/)"
  
  def generate_plugin_skeleton
    plugin_options = "--skip-gemfile --skip-bundle --skip-git --skip-test-unit"
    plugin_options += " --mountable" if options.mountable?
    plugin_options += " --full" if options.service_layer? and !options.mountable?

    generate(:plugin, "#{PLUGINS_PATH}/#{name}", plugin_options)
  end
  
  def adapt_plugin
    replace_test_with_spec
    
    if options.mountable?
      modify_application_controller
      add_routes
      add_controller_spec
    end
      
    if options.service_layer?
      update_dependencies_to_gemspec  
      create_service_layer_service
      create_service_layer_driver
    end
  end

  private
  
  def update_dependencies_to_gemspec
    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", /s.add_dependency "rails"[^\n]*\n/, ''
    gsub_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", /s.add_development_dependency "sqlite3"/, ''
    
    #inject_into_file "#{PLUGINS_PATH}/#{name}/#{name}.gemspec", after: "s.test_files = Dir[\"test/**/*\"]\n" do 
    #  "s.add_dependency \"domain_model_service_layer\""
    #end
  end
  
  def create_service_layer_service
    copy_file "app/services/service_layer/service.rb", "#{PLUGINS_PATH}/#{name}/app/services/service_layer/#{name}_service.rb"
    gsub_file "#{PLUGINS_PATH}/#{name}/app/services/service_layer/#{name}_service.rb", '%{PLUGIN_NAME}', name.classify
  end
  
  def create_service_layer_driver
    copy_file "lib/driver.rb", "#{PLUGINS_PATH}/#{name}/lib/#{name}/driver.rb"
    copy_file "lib/driver/interface.rb", "#{PLUGINS_PATH}/#{name}/lib/#{name}/driver/interface.rb"
    copy_file "lib/driver/my_driver.rb", "#{PLUGINS_PATH}/#{name}/lib/#{name}/driver/my_driver.rb"

    gsub_file "#{PLUGINS_PATH}/#{name}/lib/#{name}/driver/interface.rb", '%{PLUGIN_NAME}', name.classify
    gsub_file "#{PLUGINS_PATH}/#{name}/lib/#{name}/driver/my_driver.rb", '%{PLUGIN_NAME}', name.classify
    
    prepend_to_file "#{PLUGINS_PATH}/#{name}/lib/#{name}.rb" do
      "require \"domain_model_service_layer\""
      "require_relative \"#{name}/driver\"\n"
    end
  end
  
  def modify_application_controller
    remove_file "#{PLUGINS_PATH}/#{name}/app/controllers/#{name}/application_controller.rb"
    copy_file "app/controllers/application_controller.rb", "#{PLUGINS_PATH}/#{name}/app/controllers/#{name}/application_controller.rb"
    copy_file "app/views/application/index.html.haml", "#{PLUGINS_PATH}/#{name}/app/views/#{name}/application/index.html.haml"
    
    gsub_file "#{PLUGINS_PATH}/#{name}/app/controllers/#{name}/application_controller.rb", '%{PLUGIN_NAME}', name.classify
    gsub_file "#{PLUGINS_PATH}/#{name}/app/views/#{name}/application/index.html.haml", '%{PLUGIN_NAME}', name.classify
  end
  
  def replace_test_with_spec
    create_file "#{PLUGINS_PATH}/#{name}/spec/.keep"
  end
  
  def add_controller_spec
    copy_file "spec/controllers/application_controller_spec.rb", "#{PLUGINS_PATH}/#{name}/spec/controllers/application_controller_spec.rb"
    gsub_file "#{PLUGINS_PATH}/#{name}/spec/controllers/application_controller_spec.rb", '%{PLUGIN_NAME}', name.classify
       
    gsub_file "#{PLUGINS_PATH}/#{name}/spec/controllers/application_controller_spec.rb", '%{PLUGIN_NAME}', name.classify   
  end
  
  def add_routes
    remove_file "#{PLUGINS_PATH}/#{name}/config/routes.rb"
    copy_file "config/routes.rb", "#{PLUGINS_PATH}/#{name}/config/routes.rb"
    gsub_file "#{PLUGINS_PATH}/#{name}/config/routes.rb", '%{PLUGIN_NAME}', name.classify
  end

end
