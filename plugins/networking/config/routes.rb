Networking::Engine.routes.draw do
  resources :networks
  resources :floating_ips
  resources :security_groups
end
