Compute::Engine.routes.draw do
  resources :instances, except: [:edit, :update] do
    member do
      get 'console'
      get 'update_item'
      put 'stop'
      put 'start'
      put 'pause'
      put 'suspend'
      put 'resume'
      put 'reboot'
    end
  end

  resources :keypairs
end
