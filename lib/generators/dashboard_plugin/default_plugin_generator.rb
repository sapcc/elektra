# frozen_string_literal: true

# This class contains methods for adaption of default plugin.
class Generators::DashboardPlugin::DefaultPluginGenerator
  extend Forwardable
  def_delegators :@context, :options, :copy_file, :remove_file, :gsub_file,
                 :create_file, :name
  attr_reader :plugin_path

  def initialize(context, plugin_path)
    @context = context
    @plugin_path = plugin_path
  end

  def run
    return unless options.mountable?
    modify_application_controller
    add_routes
    update_assets
  end

  private

  def update_assets
    remove_file "#{plugin_path}/#{name}/app/assets/stylesheets/#{name}/application.css"
    remove_file "#{plugin_path}/#{name}/app/assets/javascripts/#{name}/application.js"
    copy_file 'default/app/assets/stylesheets/_application.scss', "#{plugin_path}/#{name}/app/assets/stylesheets/#{name}/_application.scss"
    copy_file 'default/app/javascript/plugin.js', "#{plugin_path}/#{name}/app/javascript/plugin.js"
  end

  def modify_application_controller
    remove_file "#{plugin_path}/#{name}/app/controllers/#{name}/application_controller.rb"
    copy_file 'default/app/controllers/application_controller.rb', "#{plugin_path}/#{name}/app/controllers/#{name}/application_controller.rb"
    copy_file 'default/app/views/application/index.html.haml', "#{plugin_path}/#{name}/app/views/#{name}/application/index.html.haml"
  end

  def add_routes
    remove_file "#{plugin_path}/#{name}/config/routes.rb"
    copy_file 'default/config/routes.rb', "#{plugin_path}/#{name}/config/routes.rb"
  end
end
