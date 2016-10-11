Loadbalancing::Engine.routes.draw do
  get '/' => 'application#index', as: :entry
  resources :loadbalancers, shallow: true do
    resources :listeners, module: :loadbalancers do
    end
    resources :pools, module: :loadbalancers do
      get :show_details, on: :member
      resources :members, module: :pools do
        collection do
          post :add
          get :add_external
        end
        member do
        end
      end
      resources :healthmonitors, module: :pools do
      end
    end
  end
end
