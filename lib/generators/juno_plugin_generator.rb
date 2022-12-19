# frozen_string_literal: true

class JunoPluginGenerator
  extend Forwardable
  def_delegators :@context,
                 :options,
                 :copy_file,
                 :remove_file,
                 :gsub_file,
                 :create_file,
                 :name,
                 :remove_dir,
                 :directory,
                 :source_paths,
                 :append_to_file
  attr_reader :plugin_path

  def initialize(context, plugin_path)
    @context = context
    @plugin_path = plugin_path
  end

  def run
    add_packs
    return unless options.mountable?

    modify_app
    add_routes
    update_assets
    add_controller_spec
  end

  private

  def update_assets
    remove_file "#{plugin_path}/#{name}/app/assets/stylesheets/#{name}/application.css"
    remove_dir "#{plugin_path}/#{name}/app/assets/javascripts"
    copy_file "juno/app/assets/stylesheets/_application.scss",
              "#{plugin_path}/#{name}/app/assets/stylesheets/#{name}/_application.scss"
  end

  def add_packs
    directory "juno/app/javascript", "#{plugin_path}/#{name}/app/javascript"
  end

  def modify_app
    remove_dir "#{plugin_path}/#{name}/app/controllers"
    directory "juno/app/controllers",
              "#{plugin_path}/#{name}/app/controllers/#{name}"
    remove_dir "#{plugin_path}/#{name}/app/views"
    directory "juno/app/views", "#{plugin_path}/#{name}/app/views/#{name}"
  end

  def add_routes
    remove_file "#{plugin_path}/#{name}/config/routes.rb"
    copy_file "juno/config/routes.rb", "#{plugin_path}/#{name}/config/routes.rb"
  end

  def add_controller_spec
    remove_file "#{plugin_path}/#{name}/spec/controllers/application_controller_spec.rb"
    copy_file "juno/spec/controllers/application_controller_spec.rb",
              "#{plugin_path}/#{name}/spec/controllers/application_controller_spec.rb"
  end
end
