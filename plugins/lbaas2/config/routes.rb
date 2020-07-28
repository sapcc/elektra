Lbaas2::Engine.routes.draw do
  root to: 'application#lbaas2_widget'
  resources :loadbalancers, only: [:index, :create, :show, :update, :destroy] do
    collection do
      get ':id/status-tree' => 'loadbalancers#status_tree', as: 'status-tree'
      get 'private-networks' => 'loadbalancers#private_networks'
      get 'private-networks/:id/subnets' => 'loadbalancers#subnets'
      get 'fips' => 'loadbalancers#fips'
      put ':id/attach_fip' => 'loadbalancers#attach_fip'
      put ':id/detach_fip' => 'loadbalancers#detach_fip'
    end

    resources :listeners, module: :loadbalancers, only: [:index, :show, :create, :update, :destroy] do

      collection do
        get 'containers' => 'listeners#containers'
        get 'items_for_select' => 'listeners#itemsForSelect'
        get 'items_no_def_pool_for_select' => 'listeners#itemsWithoutDefaultPoolForSelect'
      end

      resources :l7policies, module: :listeners, only: [:index, :show, :create, :update, :destroy] do

        resources :l7rules, module: :l7policies, only: [:index, :show, :create, :destroy] do
        end

      end

    end

    resources :pools, module: :loadbalancers, only: [:index, :show, :create, :update, :destroy] do

      collection do
        get 'items_for_select' => 'pools#itemsForSelect'
      end

      resources :healthmonitors, module: :pools, only: [:show, :create, :update, :destroy] do
      end

      resources :members, module: :pools, only: [:index, :show, :create, :update, :destroy] do

        collection do
          get 'servers_for_select' => 'members#serversForSelect'
        end

      end

    end

  end  
end
