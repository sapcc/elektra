Rails.application.routes.draw do
  mount MonsoonOpenstackAuth::Engine => '/auth'

  root :to => redirect("/#{MonsoonOpenstackAuth.configuration.default_domain_name}")
  #root to: 'services#index', domain_fid: "sap_default" #MonsoonOpenstackAuth.configuration.default_domain_name

  scope "/:domain_fid/(:project_fid)" do
    scope module: 'authenticated_user' do
      resources :instances
      resources :volumes
      resources :os_images
      resources :users, only: [:new, :create]
      resources :credentials
      resources :projects
    end
  end

  scope "/:domain_fid" do
    match '/', to: 'services#index', via: :get
  end

  scope "/system" do
    get :health, to: "health#show"
  end

end
