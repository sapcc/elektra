BlockStorage::Engine.routes.draw do
  resources :volumes do
    member do
      get 'new_snapshot'
      post 'snapshot', as: 'snapshot'
      get 'edit_attach'
      post 'attach'
      get 'edit_detach'
      get 'detach'
    end
  end
  resources :snapshots, except: [:new, :create] do

  end
end
