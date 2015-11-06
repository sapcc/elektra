Rails.application.routes.draw do
  mount MonsoonOpenstackAuth::Engine => '/auth'
  
  ###################### MOUNT PLUGINS #####################
  PluginsManager.mountable_plugins.each do |plugin|
    Logger.new(STDOUT).debug("Mount plugin #{plugin.name} as #{plugin.name}_plugin")
    mount plugin.engine_class => '/', as: "#{plugin.name}_plugin"
  end
  ######################## END ############################
    
  scope "/system" do
    get :health, to: "health#show"
  end
  
  scope "/:domain_id" do
    match '/', to: 'pages#show', id: 'landing', via: :get
  
    get 'onboarding' => 'dashboard#new_user'
    post 'register' => 'dashboard#register_user'

    scope module: 'dashboard' do
      get 'start' => 'pages#show', id: 'start', as: :domain_start

      resources :credentials
      resources :projects
      
      scope '/:project_id' do
        resources :projects
      end
    end 
  end
  
  # route for overwritten High Voltage Pages controller
  get "/pages/*id" => 'pages#show', as: :core_page, format: false
  
  root to: 'pages#show', id: 'landing'
end
