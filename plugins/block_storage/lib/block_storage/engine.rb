module BlockStorage
  class Engine < ::Rails::Engine
    isolate_namespace BlockStorage
    config.generators { |g| g.template_engine :haml }
  end
end
