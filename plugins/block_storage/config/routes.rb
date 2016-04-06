BlockStorage::Engine.routes.draw do
  resources :volumes do
    member do
      get 'new_snapshot'
      post 'snapshot', as: 'snapshot'
      get 'edit_attach'
      put 'attach'
      get 'edit_detach'
      put 'detach'
      get 'update_item'
    end
  end
  resources :snapshots, except: [:new, :create] do

  end
end
