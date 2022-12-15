module Identity
  class Engine < ::Rails::Engine
    isolate_namespace Identity

    initializer "identity.action_controller" do |app|
      ActiveSupport.on_load :action_controller do
        helper Identity::ProjectsHelper
        helper Identity::ApplicationHelper
      end
    end
  end
end
