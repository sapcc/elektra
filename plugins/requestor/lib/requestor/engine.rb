module Requestor
  class Engine < ::Rails::Engine
    isolate_namespace Requestor

    initializer 'requestor.append_migrations' do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"].push(path)
        end
      end
    end
  end

end
