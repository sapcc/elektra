module Inquiry
  class Engine < ::Rails::Engine
    isolate_namespace Inquiry

    initializer 'inquiry.append_migrations' do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"].push(path)
        end
      end
    end
    
    initializer 'inquiry.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper Inquiry::InquiriesHelper
      end
    end
  end

end
