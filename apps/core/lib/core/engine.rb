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
    
  end
end
