module Core
  class Engine < ::Rails::Engine
    isolate_namespace Core
    
    initializer 'core.append_migrations' do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"].push(path)
        end
      end
    end
    
    # initializer 'core.asset_precompile_paths' do |app|
    #   app.config.assets.precompile += ["core/manifests/*"]
    # end
    
    initializer 'core.high_voltage' do |app|
      HighVoltage.configure do |config|
        config.routes = false
        config.content_path = 'core/pages/'
      end
    end
  end
end
