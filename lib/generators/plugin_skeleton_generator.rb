# frozen_string_literal: true

# This class generates the skeleton of a dashboard plugin.
class PluginSkeletonGenerator
  extend Forwardable
  def_delegators :@context, :options, :copy_file, :remove_file, :gsub_file,
                :create_file, :generate, :name
  attr_reader :plugin_path

  def initialize(context, plugin_path)
    @context = context
    @plugin_path = plugin_path
  end

  def run
    plugin_options = '--skip-gemfile --skip-bundle --skip-git --skip-test --skip-puma --skip-javascript --skip-gemfile-entry'
    plugin_options += ' --mountable' if options.mountable?
    plugin_options += ' --full' if options.service_layer? && !options.mountable?

    generate(:plugin, "#{plugin_path}/#{name}", plugin_options)

    replace_test_with_spec
    update_dependencies_to_gemspec
    add_controller_spec
    add_policy

    create_service_layer_service if options.service_layer?
  end

  def add_policy
    copy_file 'shared/config/policy.json', "#{plugin_path}/#{name}/config/policy.json"
  end

  def create_service_layer_service
    copy_file 'shared/app/services/service_layer/service.rb', "#{plugin_path}/#{name}/app/services/service_layer/#{name}_service.rb"
  end

  def update_dependencies_to_gemspec
    remove_file "#{plugin_path}/#{name}/lib/#{name}/version.rb"
    gsub_file "#{plugin_path}/#{name}/#{name}.gemspec", "#{name.camelize}::VERSION", '"0.0.1"'
    gsub_file "#{plugin_path}/#{name}/#{name}.gemspec", "# Maintain your gem's version:\n", ''
    gsub_file "#{plugin_path}/#{name}/#{name}.gemspec", "require \"#{name}/version\"", ''
    gsub_file "#{plugin_path}/#{name}/#{name}.gemspec", /TODO:?/, ''

    gsub_file "#{plugin_path}/#{name}/#{name}.gemspec", /s.add_dependency "rails"[^\n]*\n/, ''
    gsub_file "#{plugin_path}/#{name}/#{name}.gemspec", /s.add_development_dependency "sqlite3"/, ''
  end

  def replace_test_with_spec
    create_file "#{plugin_path}/#{name}/spec/.keep"
  end

  def add_controller_spec
    copy_file 'shared/spec/controllers/application_controller_spec.rb', "#{plugin_path}/#{name}/spec/controllers/application_controller_spec.rb"
  end
end
