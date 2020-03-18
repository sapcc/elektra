Lbaas2::Engine.routes.draw do
  root to: 'application#index'
  resources :loadbalancers, only: [:index, :create, :show, :destroy] do
    collection do
      get ':id/status-tree' => 'loadbalancers#status_tree', as: 'status-tree'
      get 'private-networks' => 'loadbalancers#private_networks'
      get 'private-networks/:id/subnets' => 'loadbalancers#subnets'
    end

    resources :listeners, module: :loadbalancers, only: [:index] do
    end

    resources :pools, module: :loadbalancers, only: [:index] do
    end

  end  
end
