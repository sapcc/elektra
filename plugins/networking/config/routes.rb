Networking::Engine.routes.draw do
  resources :networks
  resources :routers
  resources :floating_ips
  resources :security_groups
end
