Rails.application.routes.draw do
  mount MonsoonOpenstackAuth::Engine => '/auth'

  # scope module: :core do
  #   root to: 'pages#show', id: 'landing'
  # end

  
  ###################### PLUGINS TEST #####################
  # mount all plugins under root path
  # mount Compute::Engine => "/"
  
  apps_path = 'apps'
  Dir.glob("#{apps_path}/*") do |gem_path|
    gem_name = gem_path.gsub("#{apps_path}/",'')
    
    engine_name = gem_name.classify
    engine_name << 's' if gem_name[-1] == 's'
    engine_class = engine_name.constantize.const_get(:Engine)
    
    mount engine_class => '/', as: "#{gem_name}_app"
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



  # scope "/system" do
  #   get :health, to: "health#show"
  # end

  # # route for overwritten High Voltage Pages controller
#   get "/pages/*id" => 'pages#show', as: :page, format: false
end
