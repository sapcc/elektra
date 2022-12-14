Cloudops::Engine.routes.draw do
  root to: "application#show", as: :start
  resources :topology_objects, only: %i[index]
end
