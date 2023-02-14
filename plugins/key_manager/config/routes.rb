KeyManager::Engine.routes.draw do
  resources :secrets, only: %i[index show new create destroy] do
    get "type_update", on: :collection
    get "payload", on: :member
  end

  resources :containers, only: %i[index show new create destroy]
end
