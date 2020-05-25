Lbaas2::Engine.routes.draw do
  root to: 'application#index'
  resources :loadbalancers, only: [:index, :create, :show, :destroy] do
    collection do
      get ':id/status-tree' => 'loadbalancers#status_tree', as: 'status-tree'
      get 'private-networks' => 'loadbalancers#private_networks'
      get 'private-networks/:id/subnets' => 'loadbalancers#subnets'
    end

    resources :listeners, module: :loadbalancers, only: [:index, :show, :create, :destroy] do

      collection do
        get 'containers' => 'listeners#containers'
        get 'items_no_def_pool_for_select' => 'listeners#itemsWithoutDefaultPoolForSelect'
      end

      resources :l7policies, module: :listeners, only: [:index, :show, :create] do

        resources :l7rules, module: :l7policies, only: [:index, :create, :destroy] do
        end

      end

    end

    resources :pools, module: :loadbalancers, only: [:index, :show, :create] do

      collection do
        get 'items_for_select' => 'pools#itemsForSelect'
      end

      resources :healthmonitors, module: :pools, only: [:show, :create] do
      end

      resources :members, module: :pools, only: [:index, :create] do

        collection do
          get 'servers_for_select' => 'members#serversForSelect'
        end

      end

    end

  end  
end
