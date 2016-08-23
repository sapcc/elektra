KeyManager::Engine.routes.draw do

  resources :secrets, only: [:index, :show, :new, :create] do
  end

  resources :containers, only: [:index] do
  end

end
