Rails.application.routes.draw do
  mount MonsoonOpenstackAuth::Engine => '/auth'

  scope '(/:domain_id)' do
    Logger.new(STDOUT).debug("Mount plugin docs as docs_plugin")
    mount Docs::Engine => '/docs', as: 'docs_plugin'
  end

  scope "/system" do
    get :health, to: "health#show"
  end

  scope "/:domain_id" do
    match '/', to: 'pages#show', id: 'landing', via: :get

    scope "(/:project_id)" do
      get 'onboarding' => 'dashboard#new_user'
      post 'register' => 'dashboard#register_user'

      ###################### MOUNT PLUGINS #####################
      PluginsManager.mountable_plugins.each do |plugin|
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
