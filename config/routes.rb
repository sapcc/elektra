Rails.application.routes.draw do
  mount MonsoonOpenstackAuth::Engine => '/auth'

  # TODO: remove after friendlyid is available
  keystone_endpoint = ENV["MONSOON_OPENSTACK_AUTH_API_ENDPOINT"] || ''
  domain_id = if keystone_endpoint.include?("mo-72302efe6")
    "9e1152e7da284ce2a026df84194aaa78"
  elsif keystone_endpoint.include?("localhost")
    'o-sap_default'
  else
    'o-135d203c5'
  end

  
  root to: 'services#index', domain_id: domain_id #MonsoonOpenstackAuth.configuration.default_domain_name

  scope "/:domain_id/(:project_id)" do
    scope module: 'authenticated_user' do
      resources :instances
      resources :volumes
      resources :os_images
      resources :users, only: [:new, :create]
      resources :credentials
      resources :projects
    end
  end

  scope "/:domain_id" do
    match '/', to: 'services#index', via: :get
  end

  scope "/system" do
    get :health, to: "health#show"
  end

end
