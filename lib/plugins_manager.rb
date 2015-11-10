require 'singleton'
class PluginsManager
  # PluginsManager is a singleton
  include Singleton
  
  attr_reader :plugins_path, :mountable_plugins
  
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
    @plugins_path = File.join(File.expand_path('../../',__FILE__),'plugins')
    
    # load gems which path starts with ROOT/plugins -> plugins
    available_plugin_specs = Gem.loaded_specs.values.select do |gemspec|
      gemspec.full_gem_path.start_with?(@plugins_path)
    end
    
    @available_plugins = {}
    @mountable_plugins = []
    
    available_plugin_specs.each do |gemspec| 
      plugin = Plugin.new(gemspec)
    
      @available_plugins[plugin.name] = plugin
      @mountable_plugins << plugin if plugin.mountable?
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
    attr_reader :name, :path

    def initialize(gemspec)
      @name = gemspec.name
      @path = gemspec.full_gem_path
    end

    # is mountable if engine class exists
    def mountable?
      !engine_class.nil?
    end

    # engine_class looks like Compute::Engine
    def engine_class
      @name.classify.constantize.const_get(:Engine) rescue nil
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
