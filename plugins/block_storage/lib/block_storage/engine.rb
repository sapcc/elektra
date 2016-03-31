module BlockStorage
  class Engine < ::Rails::Engine
    isolate_namespace BlockStorage
    config.generators do |g|
      g.template_engine :haml
    end
  end
end
