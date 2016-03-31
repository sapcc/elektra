BlockStorage::Engine.routes.draw do
  resources :volumes do
    member do
      get 'new_snapshot'
      post 'snapshot', as: 'snapshot'
      get 'assign'
      post 'attach'
      post 'detach'
    end
  end
  resources :snapshots, except: [:new, :create] do

  end
end
