Rails.application.routes.draw do
  mount MonsoonOpenstackAuth::Engine => '/auth'

  #root :to => redirect("/#{MonsoonOpenstackAuth.configuration.default_domain_name}")
  #root to: 'services#index', domain_id: "sap_default" #MonsoonOpenstackAuth.configuration.default_domain_name
  root to: 'services#index'

  scope "/:domain_id/(:project_id)" do
    scope module: 'authenticated_user' do
      resources :instances do
        member do
          get 'update_item'
          put 'stop'
          put 'start'
          put 'pause'
        end
      end
      resources :volumes
      resources :os_images
      resources :users, only: [:new, :create]
      resources :credentials

      resources :projects

      # #TEST, use scoped project id as project
      # constraints project_id: nil do |request|
      #   resources :projects, only: [:index,:new,:create]
      # end
      #
      # scope constraints: lambda {|request| request.params[:project_id].nil? ? false : (request.params[:id]=request.params[:project_id]; true) } do
      #   get 'edit', to: 'projects#edit', as: :edit_project
      #   get '/', to: 'projects#show', as: :project
      #   patch '/', to: 'projects#update'#, as: :project
      #   put '/', to: 'projects#update'#, as: :project
      #   delete '/', to: 'projects#destroy'#, as: :project
      # end



      get 'start' => 'pages#show', id: 'start'

    end
  end

  scope "/:domain_id" do
    match '/', to: 'services#index', via: :get
  end

  scope "/system" do
    get :health, to: "health#show"
  end

  # route for overwritten High Voltage Pages controller
  get "/pages/*id" => 'pages#show', as: :page, format: false


end
