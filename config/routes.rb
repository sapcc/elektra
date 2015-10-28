Rails.application.routes.draw do
  mount MonsoonOpenstackAuth::Engine => '/auth'

  root to: 'core/pages#show', id: 'landing'

  ###################### PLUGINS TEST #####################
  BootInquirer.available_apps.each do |app|
    if app.mountable?
      BootInquirer.logger.debug "Mount engine #{app.name} as #{app.name}_app"
      mount app.engine_class => '/', as: "#{app.name}_app" 
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
