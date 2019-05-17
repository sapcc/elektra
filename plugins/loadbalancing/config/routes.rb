Loadbalancing::Engine.routes.draw do
  get '/' => 'loadbalancers#index', as: :entry
  get 'listener_details/:id', to: 'loadbalancers/listeners#show', as: 'listener_details'
  resources :loadbalancers do
    collection do
      post 'update_all_status'
    end
    member do
      get 'update_status'
      get 'new_floatingip'
      put 'attach_floatingip'
      put 'refresh_state'
      delete 'detach_floatingip'
      get 'update_item'
      get 'get_item'
      get 'update_statuses'
    end

    resources :listeners, module: :loadbalancers do
      member do
        get 'update_item'
      end
      resources :l7policies, module: :listeners do
        collection do
          get :new_pre
        end
        member do
          get 'update_item'
        end
        resources :l7rules, module: :l7policies do
          member do
            get 'update_item'
          end
        end
      end
    end

    resources :pools, module: :loadbalancers do
      get :show_details, on: :member
      resources :members, module: :pools do
        collection do
          post :add
          get :add_external
        end
        member do
          get 'update_item'
        end
      end
      resources :healthmonitors, module: :pools do
      end
    end
  end
end
