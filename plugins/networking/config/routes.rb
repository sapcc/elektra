Networking::Engine.routes.draw do
  resources :networks
  resources :routers do
    get 'topology'
  end
  resources :floating_ips
  resources :security_groups
end
