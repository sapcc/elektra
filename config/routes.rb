Rails.application.routes.draw do
  mount MonsoonOpenstackAuth::Engine => '/auth'

  #root :to => redirect("/#{MonsoonOpenstackAuth.configuration.default_domain_name}")
  #root to: 'services#index', domain_id: "sap_default" #MonsoonOpenstackAuth.configuration.default_domain_name
  # root to: 'services#index'
  root to: 'pages#show', id: 'landing'


  # scope "/:domain_id" do
  #   match '/', to: 'services#index', via: :get
  #
  #   scope module: 'authenticated_user' do
  #     get 'start' => 'pages#show', id: 'start', as: :domain_start
  #
  #     resources :credentials
  #
  #     scope "/:project_id" do
  #       resources :instances do
  #         member do
  #           get 'update_item'
  #           put 'stop'
  #           put 'start'
  #           put 'pause'
  #         end
  #       end
  #       resources :volumes
  #       resources :os_images
  #       resources :users, only: [:new, :create]
  #       resources :credentials
  #       resources :projects
  #
  #       get 'start' => 'pages#show', id: 'start'
  #     end
  #   end
  # end

  scope "/:domain_id" do
    match '/', to: 'pages#show', id: 'landing', via: :get

    scope module: 'authenticated_user' do
      get 'start' => 'pages#show', id: 'start', as: :domain_start

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


      scope "/:project_id" do
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
        resources :credentials
        resources :projects

        get 'start' => 'pages#show', id: 'start'
      end

      resources :users, only: [:new, :create]
    end
  end



  scope "/system" do
    get :health, to: "health#show"
  end

  # route for overwritten High Voltage Pages controller
  get "/pages/*id" => 'pages#show', as: :page, format: false


end
