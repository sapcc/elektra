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
      
      # constraints project_id: nil do |request|
      #   get '/projects', to: 'projects#index', as: :projects
      # end
      #
      # constraints project_id: (not nil) do |request|
      #   get '/', to: 'projects#show', constraints: lambda { |request| request.params.include?(:project_id) }, as: :project
      # end
      #
      # # get '/projects', to: 'projects#index', constraints: lambda { |request| request.params[:project_id].nil? }, as: :projects
      # # get '/', to: 'projects#show', constraints: lambda { |request| request.params.include?(:project_id) }, as: :project
      # # get '/edit', to: 'projects#edit', constraints: lambda { |request| request.params.include?(:project_id) }, as: :edit_project
    end
  end

  scope "/:domain_id" do
    match '/', to: 'services#index', via: :get
  end

  scope "/system" do
    get :health, to: "health#show"
  end

end
