require 'singleton'

module Core
  class PluginsManager
    # Core::PluginsManager is a singleton
    include Singleton

    attr_reader :plugins_path, :mountable_plugins, :plugins_with_plugin_js, :plugins_with_global_js, :plugins_with_application_css

    class << self
      # delegate methods to instance
      def method_missing(name, *args, &block)
        if instance.respond_to?(name)
          instance.send(name,*args,&block)
        else
          super(name,*args,&block)
        end
      end
    end

    def initialize
      @plugins_path = File.expand_path('../../../plugins',__FILE__)

      # load gems which path starts with ROOT/plugins -> plugins
      available_plugin_specs = Gem.loaded_specs.values.select do |gemspec|
        gemspec.full_gem_path.start_with?(@plugins_path)
      end

      @available_plugins = {}
      @mountable_plugins = []
      @plugins_with_plugin_js = []
      @plugins_with_global_js = []
      @plugins_with_application_css = []

      available_plugin_specs.each do |gemspec|
        plugin = Plugin.new(gemspec)

        @available_plugins[plugin.name] = plugin
        @mountable_plugins << plugin if plugin.mountable?
        @plugins_with_plugin_js << plugin if plugin.has_plugin_js? #plugin contains an js asset named plugin.js
        @plugins_with_global_js << plugin if plugin.has_global_js? #plugin contains an js asset named global.js
        @plugins_with_application_css << plugin if plugin.has_application_css?
      end
    end

    def plugin?(name)
      @available_plugins.has_key?(name)
    end

    def has?(plugin_name)
      plugin?(plugin_name)
    end

    def plugin(name)
      @available_plugins[name]
    end

    def available_plugins
      @available_plugins.values
    end


    # Plugin class
    class Plugin
      attr_reader :name, :path, :mount_path

      PLUGIN_JS_FILE_NAME = 'plugin'
      GLOBAL_JS_FILE_NAME = 'global'

      def initialize(gemspec)
        @name = gemspec.name
        @path = gemspec.full_gem_path
        @mount_path = gemspec.metadata['mount_path']
      end

      def mount_point
        return mount_path if mount_path
        name.gsub('_','-')
      end

      # is mountable if engine class exists
      def mountable?
        !engine_class.nil?
      end

      def has_plugin_js?
        !Dir.glob(File.join(path,"app/assets/javascripts/#{name}/plugin.*")).empty?
      end

      def has_global_js?
        !Dir.glob(File.join(path,"app/assets/javascripts/#{name}/global.*")).empty?
      end

      def has_application_css?
        return false unless File.exists?(File.join(path,"app/assets/stylesheets/#{name}"))
        entries = Dir.entries(File.join(path,"app/assets/stylesheets/#{name}"))
        entries.any?{|e| e=~/.*application\..+/}
      end

      # engine_class looks like Compute::Engine
      def engine_class
        class_name = @name.camelize
        class_name.constantize.const_get(:Engine) rescue nil
      end

      # returns true if policy file exists inside plugin
      def has_policy_file?
        File.exists?(File.join(path,'config/policy.json'))
      end

      # returns policy file path or nil
      def policy_file_path
        return nil unless has_policy_file?
        File.join(path,'config/policy.json')
      end
    end
  end
end
