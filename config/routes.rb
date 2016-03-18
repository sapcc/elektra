Rails.application.routes.draw do
  mount MonsoonOpenstackAuth::Engine => '/auth'

  scope "/system" do
    get :health, to: "health#show"
  end

  scope "/:domain_id" do
    match '/', to: 'pages#show', id: 'landing', via: :get, as: :landing_page

    scope "(/:project_id)" do
      scope module: 'dashboard' do
        scope module: 'onboarding' do
          get 'onboarding'
          post 'register_without_inquiry'
          post 'register_with_inquiry'
        end
      end

      ###################### MOUNT PLUGINS #####################
      Core::PluginsManager.mountable_plugins.each do |plugin|
        next if ['docs'].include?(plugin.name)
        Logger.new(STDOUT).debug("Mount plugin #{plugin.mount_point} as #{plugin.name}_plugin")
        mount plugin.engine_class => "/#{plugin.mount_point}", as: "#{plugin.name}_plugin"
      end
      ######################## END ############################
    end
  end

  # route for overwritten High Voltage Pages controller
  get "/pages/*id" => 'pages#show', as: :core_page, format: false

  root to: 'pages#show', id: 'landing'
end
