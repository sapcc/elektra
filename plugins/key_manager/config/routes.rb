KeyManager::Engine.routes.draw do

  resources :secrets, only: [:index, :show, :new, :create, :destroy] do
    get 'type_update', :on => :collection
  end

  resources :containers, only: [:index]

end
