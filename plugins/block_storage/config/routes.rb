BlockStorage::Engine.routes.draw do
  root to: 'application#widget'
  resources :volumes do
    collection do
      get 'availability-zones' => 'volumes#availability_zones'
    end

    member do
      put 'attach'
      put 'detach'
      put 'reset-status' => 'volumes#reset_status'
      put 'extend-size' => 'volumes#extend_size'
      delete 'force-delete' => 'volumes#force_delete'
    end
  end
  
  resources :snapshots do
    member do
      put 'reset-status' => 'snapshots#reset_status'
    end
  end
end
