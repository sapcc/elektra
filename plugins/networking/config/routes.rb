Networking::Engine.routes.draw do
  resources :floating_ips
  resources :security_groups

  resources :routers do
    get 'topology'
  end

  resources :networks do
    get :access_control
  end
end
