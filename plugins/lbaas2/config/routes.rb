Lbaas2::Engine.routes.draw do
  resources :loadbalancers, only: %i[index]
end
