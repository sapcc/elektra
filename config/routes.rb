Rails.application.routes.draw do
  mount MonsoonOpenstackAuth::Engine => '/auth'
  
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
  
  ###################### PLUGINS TEST #####################
  Dir.glob("plugins/*").each do |plugin_path|
    plugin_name = plugin_path.gsub('plugins/','')
    engine_name = plugin_name.capitalize
    engine_class = engine_name.constantize.const_get(:Engine) rescue nil
    if engine_class
      Logger.new(STDOUT).debug("Mount plugin #{plugin_path} as #{plugin_name}_app")
      mount engine_class => '/', as: "#{plugin_name}_plugin" 
    end
  end
  
  ######################## END ############################
  #
  # scope "/:domain_id" do
  #   match '/', to: 'pages#show', id: 'landing', via: :get
  #   get 'onboarding' => 'dashboard#new_user'
  #   post 'register' => 'dashboard#register_user'
  #
  #   scope module: 'dashboard' do
  #     get 'start' => 'pages#show', id: 'start', as: :domain_start
  #
  #     resources :credentials
  #     resources :projects
  #
  #     scope "/:project_id" do
  #
  #
  #
  #       # resources :instances, except: [:edit, :update] do
  #       #   member do
  #       #     get 'update_item'
  #       #     put 'stop'
  #       #     put 'start'
  #       #     put 'pause'
  #       #     put 'suspend'
  #       #     put 'resume'
  #       #     put 'reboot'
  #       #   end
  #       # end
  #
  #       resources :volumes
  #       resources :os_images
  #       resources :credentials
  #       resources :projects
  #       resources :networks
  #       resources :users
  #
  #       get 'start' => 'pages#show', id: 'start'
  #     end
  #   end
  # end
end
