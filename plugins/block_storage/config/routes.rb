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
      delete 'force-delete' => 'volumes#force_delete'
    end


    # member do
    #   get 'new_snapshot'
    #   post 'snapshot', as: 'snapshot'
    #   get 'edit_attach'
    #   put 'attach'
    #   get 'edit_detach'
    #   put 'detach'
    #   get 'update_item'
    #
    #   get 'new_status'
    #   post 'reset_status'
    #   delete 'force_delete'
    # end
  end
  resources :snapshots do

    member do
      put 'reset-status' => 'snapshots#reset_status'
    end

    # member do
    #   get 'create_volume'
    #   get 'new_status'
    #   post 'reset_status'
    # end
  end
end
