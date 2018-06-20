Reports::Engine.routes.draw do
  resources :cost, controller: 'cost', only: %i[index]
end
