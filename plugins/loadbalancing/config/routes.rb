Loadbalancing::Engine.routes.draw do
  get '/' => 'loadbalancers#index', as: :entry
  get 'listener_details/:id', to: 'loadbalancers/listeners#show', as: 'listener_details'
  resources :loadbalancers do
    member do
      get 'new_floatingip'
      put 'attach_floatingip'
      delete 'detach_floatingip'
    end

    resources :listeners, module: :loadbalancers do
    end
  end
  resources :pools do
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
