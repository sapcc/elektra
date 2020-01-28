Lbaas2::Engine.routes.draw do
  root to: 'application#index'
  resources :loadbalancers, only: %i[index]
end
