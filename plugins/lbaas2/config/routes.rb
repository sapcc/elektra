Lbaas2::Engine.routes.draw do
  root to: 'application#index'
  resources :loadbalancers, only: [:index, :create] do
    collection do
      get ':id/status-tree' => 'loadbalancers#status_tree', as: 'status-tree'
      get 'private-networks' => 'loadbalancers#private_networks'
    end
  end  
end
