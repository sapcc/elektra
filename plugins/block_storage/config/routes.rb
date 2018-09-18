BlockStorage::Engine.routes.draw do
  get 'widget' => 'application#widget'
  resources :volumes do
    member do
      get 'new_snapshot'
      post 'snapshot', as: 'snapshot'
      get 'edit_attach'
      put 'attach'
      get 'edit_detach'
      put 'detach'
      get 'update_item'

      get 'new_status'
      post 'reset_status'
      delete 'force_delete'
    end
  end
  resources :snapshots, except: [:new, :create] do
    member do
      get 'create_volume'
      get 'new_status'
      post 'reset_status'
    end
  end
end
